# Diagrama de Sequência

Este diagrama mostra a ordem temporal das interações entre os componentes do sistema durante a execução do fluxo principal: o envio e validação automática de um report de barreira arquitetônica.

## Fluxo: Reportar Barreira com Validação por IA

```mermaid
sequenceDiagram
    autonumber
    actor U as 👤 Usuário
    participant App as 📱 App Flutter
    participant Auth as 🔐 Firebase Auth
    participant FS as 💾 Firestore
    participant ST as 🖼️ Cloud Storage
    participant CF as ⚙️ Cloud Function
    participant G as 🤖 Gemini IA

    U->>App: Toca em "Reportar Barreira"
    App->>App: Captura localização GPS
    App->>U: Exibe formulário de report
    U->>App: Preenche tipo, foto e descrição
    U->>App: Toca em "Enviar"
    
    App->>Auth: Verifica token do usuário
    Auth-->>App: Token válido
    
    App->>ST: Faz upload da imagem
    ST-->>App: Retorna URL da imagem
    
    App->>FS: Salva report (status: "pendente")
    FS-->>App: Confirma criação
    App-->>U: Mostra "Report enviado, validando..."
    
    Note over CF,G: Validação automática (assíncrona)
    
    ST->>CF: Trigger: nova imagem
    CF->>G: Envia imagem para análise
    G-->>CF: Retorna se imagem mostra barreira
    
    alt Imagem válida
        CF->>FS: Atualiza status para "aprovado"
        FS-->>App: Notifica via stream
        App-->>U: 🔔 "Seu report foi publicado!"
    else Imagem inválida
        CF->>FS: Atualiza status para "moderação"
        FS-->>App: Notifica via stream
        App-->>U: 🔔 "Aguardando revisão manual"
    end
```

## Fluxo: Login do Usuário

```mermaid
sequenceDiagram
    autonumber
    actor U as 👤 Usuário
    participant App as 📱 App Flutter
    participant Auth as 🔐 Firebase Auth
    participant FS as 💾 Firestore

    U->>App: Abre o aplicativo
    App->>Auth: Verifica sessão existente
    
    alt Sessão válida
        Auth-->>App: Retorna usuário autenticado
        App->>FS: Busca perfil do usuário
        FS-->>App: Retorna dados do perfil
        App-->>U: Exibe mapa principal
    else Sem sessão
        Auth-->>App: Sem usuário
        App-->>U: Exibe tela de login
        U->>App: Insere email e senha
        App->>Auth: Solicita autenticação
        Auth-->>App: Retorna token
        App->>FS: Busca/cria perfil do usuário
        FS-->>App: Retorna dados do perfil
        App-->>U: Exibe mapa principal
    end
```

## Fluxo: Consulta de Pontos Acessíveis no Mapa

```mermaid
sequenceDiagram
    autonumber
    actor U as 👤 Usuário
    participant App as 📱 App Flutter
    participant GM as 🗺️ Google Maps API
    participant FS as 💾 Firestore

    U->>App: Abre tela do mapa
    App->>GM: Solicita tiles da região da FT
    GM-->>App: Retorna mapa renderizado
    
    App->>FS: Consulta pontos acessíveis<br/>(filtro: lat/lng da FT)
    FS-->>App: Stream de pontos acessíveis
    
    App->>App: Renderiza marcadores no mapa
    App-->>U: Exibe mapa com pontos
    
    U->>App: Toca em um marcador
    App->>FS: Busca detalhes do ponto
    FS-->>App: Retorna foto, descrição, avaliações
    App-->>U: Exibe card de detalhes
    
    Note over App,FS: Stream mantém o mapa atualizado<br/>quando novos pontos são aprovados
    
    FS->>App: Novo ponto aprovado
    App->>App: Adiciona marcador dinamicamente
```

## Observações Técnicas

- **Numeração automática:** o `autonumber` adiciona números sequenciais às mensagens, facilitando a referência durante apresentações.
- **Comunicação assíncrona:** o bloco `Note over CF,G` destaca que a validação por IA ocorre em background, sem bloquear a interface do usuário.
- **Streams do Firestore:** as setas de retorno nos fluxos de validação representam atualizações em tempo real via WebSocket, característica nativa do Firestore.
- **Notação `alt`:** representa caminhos alternativos baseados em condições (equivalente ao if/else).
