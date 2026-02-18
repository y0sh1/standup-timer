# Standup Timer

Een single-page HTML standup timer met timer functionaliteit, checklist en confetti bij afronding.

## Docker

### Build en run met Docker Compose

```bash
docker-compose up -d
```

De applicatie is dan beschikbaar op http://localhost:8080

### Build en run met Docker

```bash
docker build -t standup-timer .
docker run -d -p 8080:8080 --name standup-timer standup-timer
```

### Stoppen

```bash
docker-compose down
```

of

```bash
docker stop standup-timer
docker rm standup-timer
```

## Gebruik

1. Stel het aantal personen en totale duur in
2. Klik op "Start Standup"
3. De timer verdeelt de tijd automatisch over alle personen (met 10% marge per persoon)
4. Gebruik "Volgende" om handmatig naar de volgende persoon te gaan
5. Bij afronding: feestgeluid en confetti!

## Features

- Timer met countdown per persoon
- Checklist (Gisteren/Vandaag/Blokkades)
- Automatische overgang naar volgende persoon
- Handmatige "Volgende" knop
- Pauze/Hervatten functionaliteit
- Feestelijk geluid en confetti bij afronding
- Responsive design voor groot scherm en tablet
- Fullscreen mode
- Keyboard shortcuts voor snelle bediening

## Keyboard Shortcuts

- **Spatie**: Start standup / Pauze / Hervatten
- **N**: Volgende persoon (tijdens standup)
- **F**: Afronden (bij laatste persoon)
- **R**: Reset (wanneer standup niet actief is)
- **Esc**: Setup panel tonen/verbergen
