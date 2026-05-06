# Fluxo da Jornada do Usuário

Este documento apresenta o caminho concreto percorrido pelo usuário ao utilizar o aplicativo, mostrando telas, decisões e ações em sequência. Diferente do diagrama de casos de uso (que é abstrato), a jornada mostra o fluxo real de navegação.

## Jornada Principal: Reportar uma Barreira Arquitetônica

```mermaid
flowchart TD
    Start([Usuário abre o app]) --> Logado{Está<br/>logado?}
    Logado -->|Não| Login[Tela de Login/Cadastro]
    Login --> Auth[Autentica via Firebase Auth]
    Auth --> Mapa
    Logado -->|Sim| Mapa[Visualiza mapa da FT<br/>com pontos acessíveis]
    
    Mapa --> Decisao{O que<br/>deseja fazer?}
    
    Decisao -->|Consultar| Filtra[Aplica filtros:<br/>rampas, elevadores, banheiros]
    Filtra --> VerDetalhes[Toca no marcador<br/>e vê detalhes]
    VerDetalhes --> Mapa
    
    Decisao -->|Reportar barreira| BotaoReport[Toca no botão<br/>'Reportar Barreira']
    BotaoReport --> Localizacao[App captura GPS<br/>ou usuário ajusta no mapa]
    Localizacao --> Tipo[Seleciona tipo de barreira:<br/>escada, buraco, obstáculo, etc.]
    Tipo --> Foto[Tira foto ou seleciona<br/>da galeria]
    Foto --> Descricao[Adiciona descrição<br/>opcional]
    Descricao --> Envia[Toca em 'Enviar Report']
    
    Envia --> Upload[App envia dados<br/>e imagem ao Firebase]
    Upload --> ValidaIA[Gemini analisa<br/>a imagem]
    ValidaIA --> Resultado{Imagem<br/>válida?}
    
    Resultado -->|Sim| Sucesso[✅ Report publicado<br/>no mapa]
    Resultado -->|Não| Rejeitado[⚠️ Report enviado para<br/>moderação manual]
    
    Sucesso --> Fim([Volta ao mapa<br/>com novo marcador])
    Rejeitado --> Fim
    
    Decisao -->|Validar report| ListaReports[Vê lista de reports<br/>próximos]
    ListaReports --> ConfirmaReport[Confirma se<br/>barreira ainda existe]
    ConfirmaReport --> Mapa

    style Start fill:#c8e6c9
    style Fim fill:#c8e6c9
    style Sucesso fill:#a5d6a7
    style Rejeitado fill:#ffcc80
    style ValidaIA fill:#e1bee7
```

## Jornada Secundária: Cadastro e Primeiro Acesso

```mermaid
flowchart TD
    A([Usuário baixa o app]) --> B[Tela de boas-vindas<br/>com explicação do propósito]
    B --> C{Já tem<br/>conta?}
    C -->|Não| D[Toca em 'Cadastrar']
    C -->|Sim| E[Toca em 'Entrar']
    
    D --> F[Preenche email, senha<br/>e nome]
    F --> G[Aceita termos de uso]
    G --> H[Firebase Auth cria conta]
    H --> I[Tela de tutorial<br/>3 telas explicativas]
    I --> J[Mapa da FT carregado]
    
    E --> K[Preenche email e senha]
    K --> L{Credenciais<br/>válidas?}
    L -->|Sim| J
    L -->|Não| M[Exibe erro]
    M --> K
    
    J --> Fim([Pronto para usar])

    style A fill:#c8e6c9
    style Fim fill:#c8e6c9
    style M fill:#ffcdd2
```

## Jornada Secundária: Consulta de Pontos Acessíveis

```mermaid
flowchart TD
    A([Usuário abre o app]) --> B[Mapa da FT carregado<br/>com todos os marcadores]
    B --> C[Toca no botão de filtros]
    C --> D[Seleciona categorias:<br/>♿ Rampas<br/>🛗 Elevadores<br/>🚻 Banheiros<br/>🅿️ Vagas PCD]
    D --> E[Mapa atualiza<br/>mostrando apenas<br/>os filtros selecionados]
    E --> F{Encontrou<br/>o que procurava?}
    F -->|Sim| G[Toca no marcador]
    G --> H[Vê detalhes:<br/>foto, descrição<br/>e avaliações]
    H --> I[Opcional: traça rota<br/>até o ponto]
    I --> Fim([Caminha até o local])
    F -->|Não| J[Ajusta filtros<br/>ou contribui<br/>cadastrando ponto]
    J --> E

    style A fill:#c8e6c9
    style Fim fill:#c8e6c9
```

## Princípios de Acessibilidade nas Jornadas

Como o público-alvo são pessoas com mobilidade reduzida, as jornadas foram desenhadas considerando:

- **Mínimo de toques:** ações principais acessíveis em até 3 toques a partir do mapa.
- **Captura automática de GPS:** evita digitação manual de localização.
- **Compatibilidade com leitor de tela:** todas as telas seguem padrões de acessibilidade do Material Design.
- **Áreas de toque amplas:** botões com tamanho mínimo de 48x48dp.
- **Feedback visual e textual:** toda ação tem confirmação clara.
