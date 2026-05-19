# Fluxo de Navegação entre Telas

Este documento apresenta dois diagramas de fluxo do aplicativo Cadei-Rotas: o fluxo geral de navegação entre todas as telas e o fluxo detalhado da ação principal (reportar uma barreira).

## Fluxo Geral entre Telas

```mermaid
flowchart TD
    Start([App aberto]) --> T1[Tela 1<br/>Splash com logo]
    T1 --> Primeira{Primeira vez<br/>do usuário?}

    Primeira -->|Sim| T2[Tela 2<br/>Slides de instrução<br/>4 slides]
    Primeira -->|Não| T3
    T2 --> T3[Tela 3<br/>Mapa principal<br/>com pins coloridos]

    T3 --> Acao{Ação do<br/>usuário}

    Acao -->|Toca em pin| T5[Tela 5<br/>Detalhes do pin<br/>título, foto, descrição,<br/>nº de reports]
    T5 --> T3

    Acao -->|Botão reportar| Logado{Está<br/>logado?}
    Logado -->|Não| Login[Tela de Login]
    Login --> T4
    Logado -->|Sim| T4[Tela 4<br/>Formulário de report<br/>cor → título → desc → foto]

    T4 --> Confirma{Confirmar?}
    Confirma -->|Cancelar| T3
    Confirma -->|Confirmar| Toque[Toque no mapa<br/>para posicionar pin]
    Toque --> Salva[Salva report<br/>no Firestore]
    Salva --> T3

    Acao -->|Aba usuário| T6[Tela 6<br/>Perfil do usuário<br/>nome, email, tema, sair]
    T6 -->|Aba mapa| T3
    T6 -->|Deslogar| Login

    style T1 fill:#0E5FB5,color:#fff
    style T2 fill:#E6F1FB,color:#1A1A1A
    style T3 fill:#E6F1FB,color:#1A1A1A
    style T4 fill:#D85A30,color:#fff
    style T5 fill:#E1F5EE,color:#1A1A1A
    style T6 fill:#E6F1FB,color:#1A1A1A
    style Login fill:#F5F4EE,color:#1A1A1A
```

## Fluxo Detalhado: Reportar uma Barreira

```mermaid
flowchart TD
    A[Usuário no mapa] --> B[Toca no botão<br/>'Reportar' canto inferior]
    B --> C{Logado?}
    C -->|Não| L[Redireciona<br/>para Login]
    L --> D
    C -->|Sim| D[Abre formulário<br/>de report]

    D --> E[Seleciona cor do pin]
    E --> E1{Qual cor?}
    E1 -->|Vermelho| F[Totalmente<br/>inacessível]
    E1 -->|Laranja| G[Parcialmente<br/>inacessível]

    F --> H[Preenche título]
    G --> H
    H --> I[Preenche descrição]
    I --> J[Adiciona foto]

    J --> J1{Origem<br/>da foto}
    J1 -->|Câmera| K1[Tirar foto]
    J1 -->|Galeria| K2[Selecionar foto]
    K1 --> M
    K2 --> M[Foto carregada]

    M --> N{Ação final}
    N -->|Cancelar| A
    N -->|Confirmar| O[Volta ao mapa em<br/>modo posicionamento]

    O --> P[Toque único<br/>no local exato]
    P --> Q[Pin criado e enviado<br/>para Firebase]
    Q --> R[IA valida imagem<br/>em background]
    R --> S[Pin aparece no mapa<br/>com a cor escolhida]

    style E1 fill:#534AB7,color:#fff
    style F fill:#A32D2D,color:#fff
    style G fill:#D85A30,color:#fff
    style Q fill:#0E5FB5,color:#fff
    style R fill:#534AB7,color:#fff
    style S fill:#1D9E75,color:#fff
```

## Legenda de Cores dos Pins

| Cor | Significado |
|-----|-------------|
| 🔵 Azul (`#0E5FB5`) | Local acessível (rampa, elevador, banheiro PCD) — pin fixo do sistema |
| 🟠 Laranja (`#D85A30`) | Parcialmente inacessível — reportado pelo usuário |
| 🔴 Vermelho (`#A32D2D`) | Totalmente inacessível — reportado pelo usuário |

## Telas do Aplicativo

| # | Tela | Descrição |
|---|------|-----------|
| 1 | Splash | Tela de carregamento com a logo |
| 2 | Instruções | 4 slides explicando o app (só primeira vez) |
| 3 | Mapa principal | Mapa da UnB com pins coloridos e botão de reportar |
| 4 | Formulário de Report | Cor → Título → Descrição → Foto |
| 5 | Detalhes do Pin | Informações de um pin específico |
| 6 | Perfil | Dados do usuário, tema e logout |
