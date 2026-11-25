# Relatório de Testes — Cuca Ativa

Resultado da execução do [Plano de Testes](04-Plano-de-Testes.md).

## 1. Resumo

| Tipo | Resultado |
|---|---|
| Automatizados (72 casos em 9 suítes) | **72 de 72 aprovados**, 0 falhas, 0 ignorados (execução final em 25/11/2026) |
| Manuais (16 casos) | Executados durante o desenvolvimento e na avaliação heurística (ver seção 3) |
| Avaliação heurística | 11 problemas encontrados; 2 corrigidos, 1 parcial, 8 pendentes |

## 2. Testes automatizados

### 2.1 Histórico de execuções registradas no desenvolvimento
O número de testes cresceu junto com o jogo. Os totais abaixo estão registrados no
`docs/plano-de-desenvolvimento.md`:

| Marco | Testes aprovados | Novidade |
|---|---|---|
| Regras do jogo | 25 | Pontuação, tabuleiro |
| Persistência | 35 | Histórico e salvamento |
| Histórico | 43 | Tela de histórico, formato de tempo |
| Dicas e QA | 51 | Dicas (custo, limite, par disponível); 51/51 na primeira passada completa de QA |
| Versão atual | 72 (contagem das funções de teste no código) | Ranking, escolha de imagens, tamanho da letra, tutorial salvo, restauração de estado |

### 2.2 Execução final por suíte
Executada no editor do Godot 4.7.2 com o plugin godot-ai (`test_run`), em 25/11/2026.

| Suíte | Casos | Aprovados | Falhas |
|---|---|---|---|
| test_score_rules | 6 | 6 | 0 |
| test_board_generator | 5 | 5 | 0 |
| test_game_manager | 18 | 18 | 0 |
| test_save_manager | 9 | 9 | 0 |
| test_game_ranking | 7 | 7 | 0 |
| test_card_icons | 10 | 10 | 0 |
| test_settings_manager | 7 | 7 | 0 |
| test_audio_manager | 4 | 4 | 0 |
| test_time_format | 6 | 6 | 0 |
| **Total** | **72** | **72** | **0** |

### 2.3 Defeitos encontrados e corrigidos com apoio dos testes

| Defeito | Como foi encontrado | Correção |
|---|---|---|
| "Continuar partida" na mesma sessão fazia as cartas acertadas sumirem: o salvamento guardava uma referência ao dicionário vivo, e retomar a partida limpava os dois | Caso `test_restore_state_keeps_matched_when_state_shares_the_live_dictionary` | Salvamento e restauração passaram a trabalhar com cópias |
| Canal de áudio Master ficava mudo por padrão e nenhum som tocava | Teste manual M03 | Canal Master corrigido |
| Contraste do "check" verde sobre o amarelo das Configurações era de ~1,7:1 | Auditoria de acessibilidade | Cor trocada para #185702 (~5,9:1) |

## 3. Testes manuais

| ID | Caso | Resultado | Fonte |
|---|---|---|---|
| M01 | Tutorial no primeiro acesso | Aprovado | Smoke test (Fase 3) e avaliação heurística |
| M02 | Escolher nível (16/30/40 cartas) | Aprovado | Playtest (Fase 8) e prints do Difícil |
| M03 | Acerto | Aprovado após correção do canal Master | Playtest |
| M04 | Erro | Aprovado; tempo de exibição ampliado de 0,6 s para 1,5 s (P02) | Avaliação heurística |
| M05 | Dica | Aprovado | Playtest |
| M06 | Dica indisponível | Aprovado | Playtest |
| M07 | Pausa e continuar | Aprovado (cronômetro parado conferido) | Smoke test |
| M08 | Reiniciar | Aprovado (pontos, tempo e cartas zerados) | Smoke test |
| M09 | Sair | Aprovado após correção do P07 (Sair guarda a partida) | Avaliação heurística |
| M10 | Vitória | Aprovado | Smoke test |
| M11 | Histórico | Aprovado | Smoke test |
| M12 | Autosave e retomada | Aprovado após correção da retomada na mesma sessão | Teste automatizado |
| M13 | Tamanho da letra | Aprovado | Revisão de todas as telas |
| M14 | Volume e vibração | Aprovado | Teste no celular |
| M15 | Offline | Aprovado (o app não usa rede) | — |
| M16 | Instalação do APK | Aprovado | Instalação no celular |

> Os resultados da seção 3 reúnem o que foi anotado no plano de desenvolvimento e na avaliação
> heurística. Conferir cada linha antes de entregar; se algum caso não foi de fato repetido na
> versão final, reexecutá-lo e atualizar.

## 4. Avaliação heurística (resumo)
Documento completo: `docs/avaliacao-heuristica.md`.

| Gravidade | Qtde | Problemas | Situação |
|---|---|---|---|
| 3 — grande | 2 | P01 Reiniciar/Sair sem confirmação; P02 cartas erradas viravam rápido | P02 corrigido; P01 parcial |
| 2 — pequena | 5 | P03 sem progresso de pares; P04 custo da Dica não explicado; P05 configurações não guardadas; P06 tutorial não revisável; P07 Sair não encerrava a partida | P07 corrigido; demais pendentes |
| 1 — cosmética | 4 | P08 regra de pontos; P09 detalhes do "Continuar partida"; P10 selo cobre a ilustração; P11 botão voltar do Android | Pendentes (P11 a verificar) |

Limitações: um único avaliador e ausência de teste com pessoas idosas.

## 5. Conclusão
Os testes automatizados protegem as regras centrais do jogo (pontuação, tabuleiro, salvamento,
ranking e configurações). As telas e os efeitos foram verificados manualmente e pela avaliação
heurística, que apontou melhorias registradas para a continuidade. O próximo passo recomendado é
validar o jogo com pessoas idosas e tratar os problemas pendentes.
