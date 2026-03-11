# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-10

### Otimização e Estabilidade (Fase 7)
- ✅ Otimização de inicialização assíncrona paralela (Meta: < 1.5s).
- ✅ Tratamento global de erros com diálogos amigáveis e logs (ZonedGuarded).
- ✅ Resiliência do HTTP Client com timeouts e tratamento de rede.
- ✅ Micro-interações e animações fluidas na UI (flutter_animate).
- ✅ Atalhos de teclado globais consolidados (Toggle Sidebar, Switch Theme).
- ✅ Lazy loading nativo para exploradores de serviços WSDL.

### Adicionado (Fases 1-6)
- Shell visual estilo VS Code com Sidebar redimensionável.
- Monaco Editor integrado com Syntax highlighting para XML.
- Parser robusto de WSDL 1.1 e 1.2 com suporte a recursão de XSD.
- Geração automática de templates de envelope SOAP.
- Variáveis de ambiente com interpolação dinâmica.
- Sistema de persistência local para Coleções e Histórico.
- Importação de coleções do Postman.

### Corrigido
- Vazamento de memória na troca de abas do editor.
- Inconsistência de contraste nos temas Light e Dark.

---

## 📅 Próximos Passos (Roadmap v2.0)
- Suporte a autenticação WS-Security (UsernameToken, X.509).
- Visualizador de esquemas XSD gráfico.
- Extensibilidade via plugins Javascript.

