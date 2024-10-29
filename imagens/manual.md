# Manual para o uso da aplicação

- #### [📝Documentação técnica](../README.md)

- ## Requisitos
    - ### Conexão com a internet
    - ### Dispositivo com funcionalidade biométrica
    - ### Dispositivo com funcionalidade de localizações

- ### Observações: Sempre que for solicitado o uso de algum componente do celular (Localização, Galeria, etc..) aprovar.

- ### 1. Criar os usuários ADM
    - #### Os usuários ADM são criados manualmente no FIREBASE.
- ### 2. Abrir a aplicação
    - #### 2.1 - Tela Inicial
        - ##### Ao carregar a página inicial clique no botão centralizado escrito 'Login'
    - #### 2.2 - Página de Login
        - ##### Na página de login deve ser colocado primeiramente o NIF do usuário(ADM ou Funcionário Comum), utilizando apenas números. Assim que digitar o NIF corretamente clique em 'Continuar'
        - ##### Após clicar em continuar será verificado se o NIF existe e se é o primeiro login do usuário, exceto os usuários ADM que ja foram criados manualmente no FIREBASE, caso seja o primeiro login será solicitado a criação da senha para o usuário; caso não seja, será solicitada a senha para que o usuário realize o LOGIN.
        - ##### Depois de digitar a senha basta clicar em LOGIN.
    - #### 2.3.1 - Tela de cadastro de funcionários
        - ##### Utilizada somente pelos ADM, a tela de cadastro é bem simples com um formulário básico onde deve ser preenchido corretamente com as informações do usuário (NIF, NOME e CPF) e depois cadastrar o mesmo.
    - #### 2.3.2 - Tela Interna para Funcionário
        - ##### Na tela interna principal contamos com nossas principais funcionalidades: HISTÓRICO DE REGISTROS, REALIZAR REGISTRO PONTO, FOTO DE PERFIL e HORÁRIO. Cada funcionalidade possui seu respectivo botão na tela.
    - #### 2.4 - Tela para troca de foto de perfil
        - ##### O usuário deve clicar em 'Selecionar Imagem' e escolher uma imagem da sua galeria, depois de escolher clicar em 'Upload' após feito o upload será redirecionado a tela interna principal.
    - #### 2.5 - Tela para histórico de registros
        - ##### Nessa tela é mostrado o histórico de registros de entrada e saída feito pelo usuário.
    - #### 2.6 - Tela para registrar o Ponto
        - ##### Os registros são armazenados de 2 tipos ENTRADA e SAÍDA, para isso há 2 botões na tela principal que redirecionam respectivamente a cada uma das página para o seu tipo de registro.
        - ##### Ao entrar na página é mostrado um mapa mostrando a sua distância em relação à empresa e caso for menor que 100m será possível registrar seu ponto.
        - ##### Clique em 'Registrar Ponto' e confirme utilizando sua biometria via digital.
    - #### 2.7 -  Logout
        - ##### Por fim, para sair da aplicação basta clicar em 'Logout'.
        