# <img src="./imagens/logo1.png" align="text-center">

- ##### [📝Manual de uso da aplicação](./imagens/manual.md)
- ##### [📝Documentação de testes](./imagens/testes_unitarios.md)

- ## Resumo:
  - ### O aplicativo permite ao funcionário registrar seu ponto de trabalho em seu dispositivo móvel, verificando a distância e localização que está em relação ao local de trabalho, também, é adicionado funcionalidades para verificação e segurança da identidade do funcionario, como uso da digital para registrar o ponto. Além disso, o app conta com uma interface simples atrativa e intuitiva com o usuário, permitindo que o mesmo personalize seu perfil com uma foto de perfil.

- ## Ferramentas utilizadas:
  - ### Firebase:
    - ####  Firebase Datastore
    - ####  Cloud Storage
  - ### Framework Flutter:
      - #### **Dependências Flutter utilizadas** : 
        - #### Depedências relacionadas ao Firebase: 
            - #### `firebase_core`
            - ####  `firebase_auth`
            - ####  `cloud_firestore`
            - ####  `firebase_storage`
            - ####  `firebase_messaging`
        - #### `local_auth` (Autenticação via biometria)
        - #### `geolocator` (Localização)
        - #### `flutter_map` (Mapa visual)
        - ####  `bcrypt` (Criptografia de senha)
        - ####  `image_picker` (Selecionar uma imagem da galeria)
  - ### VSCode (Desenvolvimento)
  - ### BlueStacks 5 (Emulação)
  - ### GitHub (Versionamento)

- ## Funcionalidades do aplicativo:
  - #### `Conexão com plataforma Firebase`: No aplicativo todo utilizamos varias funcionalidades que a plataforma oferece como FirebaseDatastore e CloudStorage. Dessa maneira conseguimos utilizar essas funcionalidades de qualquer dispositivo que esteja em uma rede de internet.
  - #### `Cadastro de funcionários (ADM)`: Os usuários Administradores, previamente cadastrados na base de dados do Firebase na coleção funcionários, tem direito a cadastrar novos funcionários no aplicativos, assim, cadastrando seu `NIF`, `CPF` e `NOME`
  - #### `Login de funcionários`: Após ter o usuário criado por um Administrador, o funcionário pode realizar o login e caso tenha sido recentemente cadastrado deve registrar uma nova senha, após isso ou caso não tenha sido pode seguir diretamente a página principal.
  - #### `Criptografia de senha`: Utilizando o bcrypt fizemos um sistema que criptografa e protege a senha do funcionário.
  - #### `Alteração da foto de perfil`: Para ter uma melhor interação com o funcionário, ele pode cadastrar sua foto de perfil diretamente de sua galeria e realizar o UPLOAD da foto. A imagem é salva na plataforma do Firebase utilizando o CLOUD STORAGE
  - #### `Verificação por Localização`: Desenvolvemos um sistema que verifica a distância que o colaborador está do endereço original da empresa, permitindo que ele possa registrar seu ponto em até 100m de distância do local de trabalho.
  - #### `Registro de ponto`: Uma funcionalidade simples e ágil, criamos uma página simples em que é possivel verificar a distância que o funcionário está do endereço original por meio de um mapa e caso esteja próximo registrar seu ponto. Há 2 páginas uma para os pontos de entrada e outra para os pontos de saída. Esses pontos são registrados na base de dados armazenando os Dados como `NIF`,`NOME` e `LOCALIZAÇÃO` do funcionário. 
  - #### `Verificação via Biometria`: Para garantir uma melhor segurança, antes de registrar de fato o ponto é necessário confirmar utilizando a digital cadastrada no seu dispositivo móvel.
  - #### `Histórico de Registros`: Desenvolvemos uma página onde o usuário pode ver todos os seus pontos de entrada e saída registrados. 
- ## Diagramas
  - #### Diagrama de fluxo
  - <img src="./imagens/_Fluxograma.png">

  - #### Diagrama de Classes
 ```mermaid
  classDiagram
    class Funcionario {
        -String nif
        -String nome
        -String cpf
        -bool isAdmin
        -String? senha
        +Funcionario(nif, nome, cpf, isAdmin, senha)
        +fromMap(Map~string, dynamic~ data) Funcionario
        +toMap() Map~string, dynamic~
    }
    
    class RegistroPonto {
        -String nif
        -String tipo
        -double latitude
        -double longitude
        -String distancia
        -String nome
        +RegistroPonto(nif, tipo, latitude, longitude, distancia, nome)
        +fromMap(Map~string, dynamic~ data) RegistroPonto
        +toMap() Map~string, dynamic~
    }
    
    Funcionario "1" -- "0..*" RegistroPonto : registra
  ```
