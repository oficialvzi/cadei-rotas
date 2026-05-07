# Diagrama de Componentes

Este diagrama apresenta a visão estrutural do sistema, mostrando os componentes que compõem o aplicativo de acessibilidade para cadeirantes da FT, suas responsabilidades e como se comunicam entre si.

## Diagrama

```mermaid
flowchart TB
    subgraph Cliente["📱 Aplicativo Flutter"]
        UI[Interface do Usuário<br/>Telas e Widgets]
        MAPA[Módulo de Mapa<br/>google_maps_flutter]
        AUTH_C[Módulo de Autenticação<br/>firebase_auth]
        REPORT[Módulo de Reports<br/>Captura foto + GPS]
        CACHE[Cache Local<br/>shared_preferences]
        
        UI --> MAPA
        UI --> AUTH_C
        UI --> REPORT
        UI --> CACHE
    end

    subgraph Firebase["☁️ Firebase (Backend as a Service)"]
        AUTH_S[Firebase Authentication<br/>Login/Cadastro]
        FIRESTORE[(Cloud Firestore<br/>Banco NoSQL<br/>- Usuários<br/>- Pontos Acessíveis<br/>- Reports)]
        STORAGE[(Cloud Storage<br/>Imagens dos reports)]
        AI[Firebase AI Logic<br/>Gemini API]
        FUNCTIONS[Cloud Functions<br/>Validação automática<br/>de reports]
    end

    subgraph Externos["🌐 Serviços Externos"]
        GMAPS[Google Maps API<br/>Tiles e geocoding]
        GEMINI[Google Gemini<br/>Análise de imagens]
    end

    AUTH_C -.->|autentica| AUTH_S
    REPORT -.->|envia dados| FIRESTORE
    REPORT -.->|envia foto| STORAGE
    MAPA -.->|consulta pontos| FIRESTORE
    MAPA -.->|carrega tiles| GMAPS
    
    STORAGE -->|aciona| FUNCTIONS
    FUNCTIONS -->|valida imagem| AI
    AI -->|consulta| GEMINI
    FUNCTIONS -->|atualiza status| FIRESTORE

    style Cliente fill:#0E5FB5
    style Firebase fill:#0F6E56
    style Externos fill:#534AB7
```

## Descrição dos Componentes

### Cliente (Flutter)

| Componente | Responsabilidade |
|------------|------------------|
| Interface do Usuário | Telas, widgets e navegação do aplicativo |
| Módulo de Mapa | Renderização do mapa, marcadores e interação geográfica |
| Módulo de Autenticação | Login, cadastro e gerenciamento de sessão |
| Módulo de Reports | Captura de fotos, leitura de GPS e envio de reports |
| Cache Local | Armazenamento offline de preferências e dados temporários |

### Backend (Firebase)

| Componente | Responsabilidade |
|------------|------------------|
| Firebase Authentication | Gerenciamento de identidade e tokens de acesso |
| Cloud Firestore | Persistência de usuários, pontos acessíveis e reports |
| Cloud Storage | Armazenamento das imagens enviadas pelos usuários |
| Firebase AI Logic | Interface de comunicação com o Gemini |
| Cloud Functions | Lógica de validação automática disparada por triggers |

### Serviços Externos

| Serviço | Responsabilidade |
|---------|------------------|
| Google Maps API | Fornecimento de tiles, geocoding e dados cartográficos |
| Google Gemini | Análise visual das imagens dos reports via IA |
