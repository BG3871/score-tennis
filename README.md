# Score tennis en direct par QR code

- `index.html` : tableau public de tous les courts, en temps réel (lien à partager).
- `saisie.html?c=N&k=CLE` : page de saisie d'un court (ouverte par le QR code du court).
- `admin.html?k=CLE_ADMIN` : organisateur (noms des équipes, nombre de courts, QR codes à imprimer, remise à zéro).

Base temps réel : projet Supabase `score-tennis` (tables `rencontre`, `courts`, `secrets`). Les écritures passent
uniquement par des fonctions qui vérifient la clé du court ou la clé organisateur.
