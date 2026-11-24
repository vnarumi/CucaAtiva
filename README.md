# Cuca Ativa

Jogo da memória para celular (Android), feito com **Godot 4.7** e pensado para **pessoas idosas**:
letras grandes, botões e cartas fáceis de tocar, fotos reais de animais, sons e vozes que dizem o
nome de cada animal, e nada que estresse (sem cronômetro regressivo, sem alarmes, sem punição por errar).

> Projeto acadêmico. Os requisitos estão em [`docs/requisitos.md`](docs/requisitos.md) e o histórico de
> desenvolvimento em [`docs/plano-de-desenvolvimento.md`](docs/plano-de-desenvolvimento.md).

## Como se joga

Vire duas cartas por vez e encontre os pares de animais. Cada acerto toca o som do animal, mostra
uma legenda com o nome e o som dele, e faz as cartas "dançarem". Errar só vira as cartas de volta,
sem nenhuma penalidade.

| Nível | Cartas | Animais |
|---|---|---|
| Fácil | 16 (8 pares) | Animais bem diferentes entre si |
| Médio | 30 (15 pares) | Mais variedade, algumas semelhanças |
| Difícil | 40 (20 pares) | Grupos de animais parecidos (felinos, aves pequenas, "cinzentões"…) |

No fim da partida aparece a posição no ranking do nível (mais pontos fica na frente; empate se
resolve pelo tempo).

## O que o jogo tem

- **3 níveis** de dificuldade, com 52 animais em fotos reais de perto do rosto.
- **Dica** (até 3 por partida): destaca duas cartas iguais com uma moldura amarela, sem revelar o animal.
- **Som e voz:** tom de acerto, o **nome do animal falado** e o som dele (gravação real ou, nos animais
  quase silenciosos, uma descrição falada). Legenda na tela para quem ouve mal.
- **Vibração** no acerto, no erro e na vitória, com interruptor próprio (independente do volume).
- **Histórico** de partidas vencidas, com a posição de cada uma no ranking do nível.
- **Continuar partida:** o jogo salva sozinho a partida em andamento e retoma com as mesmas figuras.
- **Tutorial** interativo na primeira vez.
- **Configurações:** volume (Desligado / Médio / Alto), tamanho da letra (Padrão / Grande / Muito
  Grande) e vibração.
- Funciona **offline** e não coleta nenhum dado do jogador.

## Acessibilidade

O projeto segue os requisitos de acessibilidade do documento (`docs/requisitos.md`):

| Requisito | Como foi atendido |
|---|---|
| RNF01 Contraste ≥ 4,5:1 (WCAG) | Texto escuro sobre fundos claros ou amarelos |
| RNF02 Textos principais ≥ 18sp | Menor texto do jogo: 18sp. Opções Grande (125%) e Muito Grande (150%) |
| RNF03 Áreas de toque ≥ 48dp | Cartas de ~74 dp no Médio/Difícil e ~93 dp no Fácil; botões maiores que 48 dp |
| RNF04 Ambiente amigável | Sem cronômetro regressivo, sem alarmes e sem elementos punitivos |

## Como rodar

1. Instale o **Godot 4.7.2** (versão "stable", sem .NET): <https://godotengine.org/download>.
2. Abra o Godot, clique em **Importar** e escolha o arquivo `project.godot` desta pasta.
3. Aperte **F5** para jogar. Para abrir só uma tela, abra a cena (por exemplo
   `scenes/game/tutorial.tscn`) e aperte **F6**.

O projeto usa o renderizador **GL Compatibility** e tela vertical de 412 × 917.

### Testes

Os testes ficam em `tests/` e usam o `McpTestSuite` que acompanha o plugin Godot AI
(`addons/godot_ai/testing/test_suite.gd`). Veja [`tests/README.md`](tests/README.md).

## Gerar o APK (Android)

1. Instale o Android Studio (SDK), um **JDK 17** e os *export templates* do Godot 4.7.2
   (Editor → Gerenciar Templates de Exportação).
2. No Godot, em Editor → Configurações do Editor → Export → Android, aponte o caminho do SDK e do JDK 17.
3. Projeto → Exportar… → **Android** → Exportar Projeto.

O preset já está configurado (`export_presets.cfg`): pacote `com.cucaativa`, retrato, Android 8.0
ou superior (SDK mínimo 26), arquitetura arm64 e a permissão de vibrar. A chave de assinatura
**não** está no repositório: crie a sua em Opções de exportação → Keystore.

Para instalar no celular, copie o `.apk` para o aparelho e toque nele (pode ser preciso permitir
instalação de "fontes desconhecidas").

## Estrutura

```
scenes/        Telas (menu, dificuldade, tabuleiro, histórico, configurações, tutorial)
scripts/
  autoload/    GameManager, SaveManager, AudioManager, SettingsManager
  core/        Regras puras (pontuação, tabuleiro, ranking, sorteio de animais, legendas)
  ui/          Scripts das telas
assets/
  icons/cards/ Fotos dos animais (facil/, medio/, dificil/) e o verso das cartas
  audio/       Sons e nomes falados dos animais (veja CREDITOS.md)
  fonts/       Fredoka One e Gabarito
  theme/       Tema compartilhado (cores, botões)
tests/         Testes automatizados
docs/          Requisitos, plano de desenvolvimento e notas de design
```

> A pasta `addons/godot_ai` é uma ferramenta de desenvolvimento (plugin Godot AI) e **não entra no APK**.

## Créditos

- **Sons dos animais:** gravações de domínio público, CC0 e Pixabay. Autores e licenças em
  [`assets/audio/animals/CREDITOS.md`](assets/audio/animals/CREDITOS.md). O som do porco é
  **CC BY 3.0** (autor: erdie).
- **Vozes (nomes e descrições):** gerados com o [Piper](https://github.com/OHF-Voice/piper1-gpl),
  voz *pt_BR-faber-medium* (dataset CC0).
- **Fotos dos animais:** geradas com ferramenta de inteligência artificial.
- **Fontes:** Fredoka One e Gabarito (Google Fonts, licença SIL Open Font).
