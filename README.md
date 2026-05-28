# 📅 Agenda de Compromissos

Aplicativo mobile/web desenvolvido com **Flutter** e **Firebase**, permitindo que o usuário gerencie seus compromissos pessoais de forma segura e prática.

---

## 📋 Descrição

O app permite criar, visualizar, editar e excluir compromissos após autenticação. Cada usuário visualiza apenas seus próprios dados, garantindo privacidade.

---

## ✅ Funcionalidades Principais

- 🔐 **Cadastro** de conta com e-mail e senha
- 🔑 **Login** e **Logout** com proteção de telas
- ➕ **Criar** compromisso (título, descrição, data e hora)
- 📋 **Listar** compromissos em ordem cronológica
- ✏️ **Editar** compromisso existente
- 🗑️ **Excluir** compromisso com confirmação
- ⚠️ Validação de formulários e tratamento de erros

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Função |
|---|---|
| Flutter | Framework de desenvolvimento multiplataforma |
| Dart | Linguagem de programação |
| Firebase Auth | Autenticação de usuários |
| Cloud Firestore | Banco de dados em tempo real |
| intl | Formatação de datas |

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                         # Ponto de entrada, roteamento por auth
├── models/
│   └── appointment.dart              # Modelo de dados do compromisso
├── services/
│   ├── auth_service.dart             # Login, cadastro, logout
│   └── database_service.dart        # CRUD no Firestore
├── screens/
│   ├── login_screen.dart             # Tela de login
│   ├── register_screen.dart          # Tela de cadastro
│   ├── home_screen.dart              # Lista de compromissos
│   └── appointment_form_screen.dart  # Formulário (criar/editar)
└── widgets/
    └── appointment_card.dart         # Card reutilizável de compromisso
```

---

## 🚀 Como Executar o Projeto

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado
- Conta no [Firebase](https://firebase.google.com)
- Android Studio ou VS Code com extensão Flutter

### Passos

1. **Clone o repositório**
   ```bash
   git clone https://github.com/seu-usuario/agenda_compromissos.git
   cd agenda_compromissos
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Configure o Firebase**
   - Acesse o [Firebase Console](https://console.firebase.google.com)
   - Crie um novo projeto
   - Adicione um app Android e/ou iOS/Web
   - Ative o **Firebase Authentication** (método: E-mail/Senha)
   - Ative o **Cloud Firestore** (modo de teste para desenvolvimento)
   - Instale o FlutterFire CLI e execute:
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
   - Isso gera automaticamente o arquivo `lib/firebase_options.dart`

4. **Atualize o `main.dart`** para usar as opções geradas:
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

5. **Execute o app**
   ```bash
   flutter run
   ```

### Regras do Firestore (recomendado para produção)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /appointments/{id} {
      allow read, write: if request.auth != null
        && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null
        && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

---

## 🔒 Autenticação

A autenticação é feita via **Firebase Authentication** com e-mail e senha.

- O `AuthService` encapsula login, cadastro e logout
- O `main.dart` usa um `StreamBuilder` para escutar o estado de autenticação em tempo real
- Telas protegidas são acessíveis apenas com sessão ativa
- Erros como "e-mail já cadastrado", "senha fraca" e "credenciais inválidas" são tratados e exibidos ao usuário

---

## 💾 Banco de Dados

O **Cloud Firestore** armazena os compromissos na coleção `appointments`.

Cada documento contém:

| Campo | Tipo | Descrição |
|---|---|---|
| `title` | String | Título do compromisso |
| `description` | String | Descrição/observação |
| `dateTime` | String (ISO 8601) | Data e hora |
| `userId` | String | UID do usuário dono |

Os dados são filtrados por `userId` para que cada usuário veja apenas seus próprios compromissos.

---

## 👨‍💻 Autor

Desenvolvido como projeto acadêmico para a disciplina de Desenvolvimento Mobile/Web.
