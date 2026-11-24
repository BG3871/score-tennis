-- Étape 1 du plan : sponsors affichés sur le tableau et compteur de vues.

-- Sponsors : liste [{ "nom": "...", "logo": "https://...", "texte": "..." }]
alter table rencontre add column if not exists sponsors jsonb not null default '[]'::jsonb;

create or replace function admin_sponsors(p_admin text, p_sponsors jsonb)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from secrets where nom = 'admin' and cle = p_admin) then
    raise exception 'cle admin invalide';
  end if;
  if jsonb_typeof(p_sponsors) <> 'array' or jsonb_array_length(p_sponsors) > 20 then
    raise exception 'liste de sponsors invalide';
  end if;
  update rencontre set sponsors = (
    select coalesce(jsonb_agg(jsonb_build_object(
      'nom', left(coalesce(s->>'nom', ''), 60),
      'logo', case when coalesce(s->>'logo', '') ~* '^https://' then left(s->>'logo', 500) else '' end,
      'texte', left(coalesce(s->>'texte', ''), 120))), '[]'::jsonb)
    from jsonb_array_elements(p_sponsors) s
    where coalesce(s->>'nom', '') <> '' or coalesce(s->>'logo', '') <> ''
  ), updated_at = now() where id = 1;
end $$;

-- Compteur de vues par jour et par page (aucune donnée personnelle).
create table if not exists visites (
  jour date not null default current_date,
  page text not null,
  n integer not null default 0,
  primary key (jour, page)
);
alter table visites enable row level security;  -- aucune lecture publique

create or replace function compter_visite(p_page text)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_page not in ('tableau', 'tv', 'widget', 'saisie') then return; end if;
  insert into visites(jour, page, n) values ((now() at time zone 'Europe/Paris')::date, p_page, 1)
  on conflict (jour, page) do update set n = visites.n + 1;
end $$;

create or replace function admin_stats(p_admin text)
returns table(jour date, page text, n integer) language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from secrets where nom = 'admin' and cle = p_admin) then
    raise exception 'cle admin invalide';
  end if;
  return query select v.jour, v.page, v.n from visites v where v.jour > current_date - 120 order by v.jour desc, v.page;
end $$;

revoke all on function admin_sponsors(text, jsonb), compter_visite(text), admin_stats(text) from public;
grant execute on function admin_sponsors(text, jsonb), compter_visite(text), admin_stats(text) to anon, authenticated;
