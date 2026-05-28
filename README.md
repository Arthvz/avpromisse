# Agenda de Compromissos

App de agenda pessoal desenvolvido em **Flutter** com **Firebase**, onde cada usuário gerencia seus próprios compromissos de forma segura.

## Funcionalidades

- Cadastro e login com e-mail e senha (Firebase Auth)
- Criar, listar, editar e excluir compromissos
- Dados isolados por usuário via Firestore
- Validação de formulários e tratamento de erros

## Tecnologias

- Flutter / Dart
- Firebase Auth
- Cloud Firestore
- intl (formatação de datas)

## Estrutura

```
lib/
├── main.dart                         # Entrada e roteamento por auth
├── models/appointment.dart           # Modelo do compromisso
├── services/
│   ├── auth_service.dart             # Login, cadastro, logout
│   └── database_service.dart         # CRUD no Firestore
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart              # Lista de compromissos
│   └── appointment_form_screen.dart  # Criar/editar
└── widgets/appointment_card.dart
```

## Como rodar

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado
- Projeto no [Firebase Console](https://console.firebase.google.com) com **Authentication (E-mail/Senha)** e **Cloud Firestore** ativados

### Clonar e instalar dependências

```bash
git clone https://github.com/Arthvz/avpromisse.git
cd avpromisse
flutter pub get
```

### Configurar o Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Isso gera o `lib/firebase_options.dart` com as credenciais do seu projeto.

### Rodar

```bash
flutter run            # roda no dispositivo/emulador conectado
flutter run -d chrome  # roda na web
```

### Buildar

```bash
flutter build apk       # Android
flutter build ios       # iOS
flutter build web       # Web
```

## Regras recomendadas do Firestore

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

## Modelo de dados

Coleção `appointments`:

| Campo         | Tipo              | Descrição              |
|---------------|-------------------|------------------------|
| `title`       | String            | Título                 |
| `description` | String            | Descrição              |
| `dateTime`    | String (ISO 8601) | Data e hora            |
| `userId`      | String            | UID do dono do registro |

---

Projeto acadêmico — Desenvolvimento Mobile/Web.
