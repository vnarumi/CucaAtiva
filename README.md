# Cuca Ativa

Jogo da memória para dispositivos Android, desenvolvido com o motor **Godot 4.7** e destinado ao
público idoso. A interface prioriza a legibilidade e a facilidade de uso: textos ampliáveis, áreas de
toque generosas, fotografias de animais, reforço sonoro e visual a cada jogada e ausência de elementos
que provoquem ansiedade, como cronômetro regressivo, alarmes ou penalidades por erro.

Trabalho de caráter acadêmico. Os requisitos funcionais e não funcionais estão descritos em
`docs/requisitos.md`, e o registro do desenvolvimento em `docs/plano-de-desenvolvimento.md`.

## Objetivo do jogo

O jogador vira duas cartas por vez com o objetivo de localizar todos os pares de animais. A cada par
encontrado, o jogo reproduz o nome do animal e o seu som característico, exibe uma legenda com essas
informações e aplica uma animação suave às cartas. Em caso de erro, as cartas apenas retornam à
posição inicial, sem qualquer penalização.

Ao final da partida, é apresentada a classificação obtida no ranking do respectivo nível. A
classificação considera a pontuação (quanto maior, melhor) e, em caso de empate, o menor tempo.

## Níveis de dificuldade

| Nível | Cartas | Características dos animais |
|---|---|---|
| Fácil | 16 (8 pares) | Animais com aparência bastante distinta entre si |
| Médio | 30 (15 pares) | Maior variedade, com algumas semelhanças |
| Difícil | 40 (20 pares) | Grupos de animais semelhantes (felinos, pequenas aves, grandes mamíferos de pelagem cinza etc.) |

## Funcionalidades

- Três níveis de dificuldade, com 52 animais retratados em fotografias de aproximação do rosto.
- **Dica** (até três por partida): destaca duas cartas iguais por meio de uma moldura amarela
  pulsante, sem revelar o animal.
- **Reforço sonoro:** tom de acerto, nome do animal falado e som do animal. Para os animais que
  emitem pouco ou nenhum som, é reproduzida uma descrição falada.
- **Legenda** na tela com o nome e a descrição do som do animal, voltada a usuários com perda auditiva.
- **Vibração** nos eventos de acerto, erro e vitória, com opção de ativação independente do volume.
- **Histórico** das partidas vencidas, com a classificação de cada uma no ranking do seu nível.
- **Continuação de partida:** o estado do jogo é salvo automaticamente e pode ser retomado, mantendo
  as mesmas figuras.
- **Tutorial interativo**, exibido no primeiro acesso.
- **Configurações:** volume (Desligado, Médio ou Alto), tamanho da letra (Padrão, Grande ou Muito
  Grande) e vibração.
- Funcionamento totalmente *offline*, sem coleta de dados do usuário.

## Acessibilidade

O projeto atende aos requisitos de acessibilidade definidos em `docs/requisitos.md`:

| Requisito | Atendimento |
|---|---|
| RNF01 – Contraste mínimo de 4,5:1 (WCAG) | Texto escuro sobre fundos claros ou amarelos |
| RNF02 – Textos principais com no mínimo 18 sp | O menor texto do jogo possui 18 sp; estão disponíveis os tamanhos Grande (125%) e Muito Grande (150%) |
| RNF03 – Áreas de toque de no mínimo 48 dp | Cartas com cerca de 74 dp (Médio e Difícil) e 93 dp (Fácil); botões superiores a 48 dp |
| RNF04 – Ambiente amigável | Ausência de cronômetro regressivo, de alarmes e de elementos punitivos |

## Execução do projeto

1. Instalar o **Godot 4.7.2** (versão estável, sem suporte a .NET), disponível em
   https://godotengine.org/download.
2. No Godot, selecionar **Importar** e escolher o arquivo `project.godot` na raiz do repositório.
3. Executar o jogo com a tecla **F5**. Para executar apenas uma tela, abrir a cena correspondente
   (por exemplo, `scenes/game/tutorial.tscn`) e pressionar **F6**.

O projeto utiliza o renderizador *GL Compatibility* e resolução vertical de 412 × 917.

### Testes automatizados

Os testes localizam-se em `tests/` e utilizam a classe `McpTestSuite`, fornecida pelo plugin Godot AI
(`addons/godot_ai/testing/test_suite.gd`). Instruções adicionais constam em `tests/README.md`.

## Geração do APK (Android)

1. Instalar o Android Studio (SDK do Android), o **JDK 17** e os *export templates* do Godot 4.7.2
   (menu Editor → Gerenciar Templates de Exportação).
2. Em Editor → Configurações do Editor → Export → Android, informar o caminho do SDK e do JDK 17.
3. Em Projeto → Exportar, selecionar o preset **Android** e escolher **Exportar Projeto**.

O preset está configurado em `export_presets.cfg`: identificador de pacote `com.cucaativa`,
orientação retrato, Android 8.0 ou superior (SDK mínimo 26), arquitetura arm64 e permissão de
vibração. A chave de assinatura **não** integra o repositório e deve ser criada pelo responsável pela
distribuição, nas opções de exportação (Keystore).

Para instalar o aplicativo em um aparelho, basta transferir o arquivo `.apk` e abri-lo no
dispositivo, autorizando a instalação de fontes desconhecidas quando solicitado.

## Estrutura do repositório

```
scenes/        Telas do jogo (menu, dificuldade, tabuleiro, histórico, configurações, tutorial)
scripts/
  autoload/    Gerenciadores globais: GameManager, SaveManager, AudioManager, SettingsManager
  core/        Regras independentes de interface (pontuação, tabuleiro, ranking, sorteio, legendas)
  ui/          Scripts das telas
assets/
  icons/cards/ Fotografias dos animais (facil/, medio/, dificil/) e verso das cartas
  audio/       Sons e nomes falados dos animais (ver CREDITOS.md)
  fonts/       Fontes Fredoka One e Gabarito
  theme/       Tema visual compartilhado
tests/         Testes automatizados
docs/          Requisitos, plano de desenvolvimento e notas de design
```

A pasta `addons/godot_ai` contém uma ferramenta auxiliar de desenvolvimento (plugin Godot AI) e não
é incluída no APK gerado.

## Créditos e licenças

- **Sons dos animais:** gravações em domínio público, sob licença CC0 ou disponibilizadas pelo
  Pixabay. Os autores e as licenças estão listados em `assets/audio/animals/CREDITOS.md`. O som do
  porco é licenciado sob **CC BY 3.0** (autor: erdie).
- **Vozes (nomes e descrições):** geradas com o software Piper
  (https://github.com/OHF-Voice/piper1-gpl), utilizando a voz *pt_BR-faber-medium*, treinada com
  conjunto de dados sob licença CC0.
- **Fotografias dos animais:** geradas por meio de ferramenta de inteligência artificial.
- **Fontes:** Fredoka One e Gabarito, distribuídas pelo Google Fonts sob a licença SIL Open Font.
