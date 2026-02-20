# TypeScript Guidelines

## Start from the beginning

The best way to approach typing in an application is always from the foundations, defining the types of your data at the first moment it appears in your code.

- In a backend application that queries a database, start by typing your database models.
- In a frontend application that queries an API, start by typing the API responses.

You can save a lot of work by adding libraries to your stack that generate types automatically (TypeScript ORMs, API clients, Swagger/OpenAPI codegen, GraphQL codegen...).

## Don't repeat yourself

Never repeat types, use and abuse [generics](https://www.typescriptlang.org/docs/handbook/2/generics.html) and [utility types](https://www.typescriptlang.org/docs/handbook/utility-types.html) to derive them.

Some examples:

```ts
// This auxiliary type defines the return type of our REST client that responds with a type to be defined for each request
export type APIRequest<T> = Promise<{ data: T; statusCode: number }>;

// Each different user role
export enum UserRole {
  ADMIN = "admin",
  USER = "user",
}

// User interface as returned from the backend
export type User = {
  email: string;
  name: string;
  phone: number;
  role: UserRole;
  productIds?: number[];
};

// So, our user request response will be
export type UserRequestResponse = APIRequest<User>;

// Suppose the user creation form UI doesn't allow defining every User field, so we pick only what we need using Pick
// Also, for demonstration purposes, imagine that the form is filled in different steps and is not fully completed from the beginning,
// so we can mark every field as optional (?) using Partial
export type CreateUserFormData = Partial<Pick<User, "email" | "name" | "phone">>;

// But for the method that will send the request, those fields are required, so we can remove every optional field (?) with Required
export type CreateUserPayload = Required<CreateUserFormData>;

// When obtaining the new user response, it could be useful to populate the user products with the full product objects obtained
// from other requests, so the user returned from the method once populated could be:
export type PopulatedUser = Omit<User, "productIds"> & { products: Product[] };

// In a React application, suppose a card component that exposes User information, its props could be
export type UserCardProps = {
  user: PopulatedUser
}
export const UserCard = ({ user }: UserCardProps) => { ... }
```

## Prefer types over interfaces

Use `type` instead of `interface` for defining object shapes and other type aliases. `type` is more versatile and consistent across different use cases.

**Advantages of `type`:**

- Can represent unions, intersections, tuples, mapped types, and conditional types — `interface` cannot
- More consistent: one syntax for all type definitions
- Cannot be declaration-merged (prevents accidental augmentation from other files)
- Works more naturally with utility types (`Pick`, `Omit`, `Partial`, etc.)

What `type` can do that `interface` cannot:

```ts
// ✅ type can represent unions
type Status = "pending" | "active" | "disabled";

// ✅ type can represent intersections concisely
type AdminUser = User & { permissions: string[] };

// ✅ type can represent tuples
type Coordinate = [number, number];

// ✅ type can use mapped and conditional types
type Readonly<T> = { readonly [K in keyof T]: T[K] };
type NonNullableFields<T> = { [K in keyof T]: NonNullable<T[K]> };

// ❌ None of the above are possible with interface
```

Declaration merging pitfall:

```ts
// ⚠️ interface allows declaration merging, which can cause unexpected behavior
// In file user.ts
interface User {
  name: string;
  email: string;
}

// In another file or even the same file
interface User {
  role: string; // This silently merges into the original User interface
}

// Now User has name, email, AND role — which may be unintended

// ✅ type does not allow declaration merging — redeclaring causes a compile error
type User = {
  name: string;
  email: string;
};

type User = { // ❌ Error: Duplicate identifier 'User'
  role: string;
};
```

> **Exception:** `interface` is acceptable when you intentionally need declaration merging (e.g., augmenting third-party library types or extending `Window`).

## Use explicit return types for complex functions

Functions returning complex types that aren't easily inferred must have explicit return type annotations. Simple functions with obvious inference don't need them.

**Why explicit return types matter:**

- Acts as documentation of the function contract
- Catches implementation errors at the function boundary, not at distant call sites
- Prevents accidental return type changes from silently propagating
- Produces better, more localized error messages

**Problems when omitted:**

- A small implementation change can accidentally alter the inferred return type, breaking callers far away
- Error messages appear at call sites instead of at the function definition
- Harder to understand what a function returns without reading its full implementation

Accidental return type change without explicit annotation:

```ts
// ❌ Bad: No explicit return type
function getUserDisplayData(user: User) {
  return {
    fullName: `${user.firstName} ${user.lastName}`,
    email: user.email,
    role: user.role,
  };
}

// Later, someone refactors and accidentally changes the return shape:
function getUserDisplayData(user: User) {
  return {
    fullName: `${user.firstName} ${user.lastName}`,
    email: user.email,
    role: user.role,
    // Accidentally added — now the inferred return type changes silently
    internalId: user.id,
  };
}

// The error only surfaces far away at call sites:
// "Property 'internalId' does not exist on type..." — confusing and hard to trace
```

```ts
// ✅ Good: Explicit return type catches the mistake immediately at the function
type UserDisplayData = {
  fullName: string;
  email: string;
  role: UserRole;
};

function getUserDisplayData(user: User): UserDisplayData {
  return {
    fullName: `${user.firstName} ${user.lastName}`,
    email: user.email,
    role: user.role,
    internalId: user.id, // ❌ Error right here: 'internalId' does not exist in type 'UserDisplayData'
  };
}
```

When explicit return types aren't needed:

```ts
// Simple functions with obvious inference don't need explicit return types
const add = (a: number, b: number) => a + b;
const isActive = (user: User) => user.status === "active";
const toUpperCase = (value: string) => value.toUpperCase();
```

## Use named types, avoid anonymous types

Prefer named types over inline/anonymous type literals. Named types improve reusability, readability, and maintainability.

**Advantages:**

- Reusable across the codebase
- Better error messages — TypeScript shows the type name instead of the full expanded structure
- Self-documenting: a name communicates intent
- Easier refactoring — change the type definition in one place
- Better IDE experience (hover tooltips show meaningful names)

**Problems with anonymous types:**

- Cannot be reused, leading to duplication
- Error messages show the full object structure, making them hard to read
- No single source of truth — changes must be made in every occurrence

Anonymous types causing duplication and poor readability:

```ts
// ❌ Bad: Anonymous types repeated across the codebase
function filterUsers(
  users: User[],
  filters: { status: string; role: string; active: boolean },
): User[] {
  // ...
}

function buildFilterQuery(
  filters: { status: string; role: string; active: boolean },
): string {
  // ...
}

// If the filter shape changes, you have to update it everywhere
// Error messages will show the full object structure:
// "Argument of type '{ status: string; }' is not assignable to
//  parameter of type '{ status: string; role: string; active: boolean }'"
```

```ts
// ✅ Good: Named type used everywhere
type UserFilters = {
  status: string;
  role: string;
  active: boolean;
};

function filterUsers(users: User[], filters: UserFilters): User[] {
  // ...
}

function buildFilterQuery(filters: UserFilters): string {
  // ...
}

// Single source of truth — change in one place
// Error messages are clear:
// "Argument of type '{ status: string; }' is not assignable to
//  parameter of type 'UserFilters'"
```

Anonymous types in React components:

```ts
// ❌ Bad: Anonymous prop types
const UserCard = ({ name, email, role }: { name: string; email: string; role: string }) => {
  // ...
};

// ✅ Good: Named prop types
type UserCardProps = {
  name: string;
  email: string;
  role: string;
};

const UserCard = ({ name, email, role }: UserCardProps) => {
  // ...
};
```

### Export every type

In an ideal world, all libraries would export the types of the objects they provide access to. Unfortunately, this is not always the case, so export every type you create.
If you find yourself working with types that you don't have direct access to, create your derivatives as soon as possible.
Unwrapping an inaccessible type can be too complex and is often a verbose and difficult-to-read operation. If all types were exported, we could avoid things like:

```ts
// Imagine an external library that doesn't export its types
// We have to 'unwrap' the types we need
type OperationResult<T> = Awaited<ReturnType<typeof calculationLib["calculateNow"] extends (arg: infer A) => infer R ? (arg: T) => R : never>>;

type OperationData = { a: number; b: number };
const data: OperationData = { a: 2, b: 3 };

// Complex usage with extensive type annotations
const result: OperationResult<OperationData> = await calculationLib.calculateNow(
  data,
  { someOptions: { operation: 'a + b', someFlag: true } }
);

// Trying to extract option types
type SumOptions = Omit<Parameters<(typeof calculationLib)["calculateNow"]<OperationData>>[1]["someOptions"], 'operation'>;

// Helper function to simplify usage, but with complex types
const sum = (a: number, b: number, options: SumOptions): Promise<OperationResult<OperationData>> =>
  calculationLib.calculateNow(
    { a, b },
    { someOptions: { operation: 'a + b', ...options } }
  );

const sumResult = sum(3, 5, { someFlag: false });
```

Instead of the above, with exported types it would be simpler:

```ts
import { Operation, OperationOptions, OperationResult } from "calculation-lib";

const sum = (
  a: number,
  b: number,
  options: Omit<OperationOptions, "operation">,
): Promise<OperationResult<number>> =>
  calculationLib.calculateNow({ a, b }, { operation: "a + b", ...options });
```

### Avoid casting when possible

Excessive use of casting (`as Type`, `<Type>value`) often indicates problems in the design of types or the structure of the code. If you find yourself using many casts, you may be fighting against the type system rather than leveraging it.

Casts create blind spots in the type system, as you're telling the compiler to "trust you" rather than properly verifying types. This can lead to runtime errors that are difficult to detect.

```ts
// ❌ Bad: Excessive use of casting
function processData(data: any) {
  const user = data as User;
  const products = (data.items as any[]).map((item) => item as Product);
  return {
    user,
    products,
    total: data.total as string as unknown as number,
  };
}
```

#### Alternatives to casting

1. **Type Guards**: Functions that help TypeScript recognize types at runtime.

```ts
function isString(value: unknown): value is string {
  return typeof value === "string";
}

function processValue(value: unknown) {
  if (isString(value)) {
    // Here TypeScript knows that value is a string
    return value.toUpperCase();
  }
  return String(value);
}
```

2. **Assertion Functions**: Functions that throw an error if the condition is not met.

```ts
function assertIsString(value: unknown): asserts value is string {
  if (typeof value !== "string") {
    throw new Error("Value must be a string");
  }
}

function processValue(value: unknown) {
  assertIsString(value);
  // Here TypeScript knows that value is a string
  return value.toUpperCase();
}
```

3. **Validation Schemas**: Use libraries like Zod, io-ts, or Ajv to validate and type data simultaneously.

```ts
import { z } from "zod";

const UserSchema = z.object({
  email: z.string().email(),
  name: z.string(),
  age: z.number().int().positive(),
});

type User = z.infer<typeof UserSchema>;

function processUser(data: unknown) {
  // Validates and converts data to User
  const user = UserSchema.parse(data);

  // user is fully typed as User
  return `${user.name} (${user.email})`;
}
```

The goal should always be to create code that is type-safe by design, rather than forcing types with casting.

### Don't carry nullable values in function parameters

An important principle in type design is to avoid "carrying" nullable values (`null` or `undefined`) through the function chain. If a parameter can be nullable, it's better to handle it as early as possible in your code.

When you allow nullable values to propagate through multiple functions, each function needs to check if the value is nullable, which causes:

1. Code repetition (each function repeats the same checks)
2. Increased complexity (code full of conditional checks)
3. Higher probability of errors (if a check is forgotten)
4. Less readable and harder to maintain code

```ts
// ❌ Bad: Propagating nullable values through multiple functions
function getUserByEmail(email: string | null): User | null {
  if (!email) return null;
  return findUser(email);
}

function getUserName(email: string | null): string {
  const user = getUserByEmail(email);
  // Now we have to check again if user is null
  return user ? user.name : "Unknown User";
}

function greetUser(email: string | null): string {
  const name = getUserName(email);
  return `Hello, ${name}!`;
}

// This works, but each function must handle the null case
const greeting = greetUser(email);
```

Instead, it's better to validate nullable values as early as possible and work only with non-nullable values:

```ts
// ✅ Good: Early handling of nullable values
function getUserByEmail(email: string): User | null {
  return findUser(email);
}

function getUserName(user: User): string {
  return user.name;
}

function greetUser(name: string): string {
  return `Hello, ${name}!`;
}

// Handling the nullable case in one place
function processGreeting(email: string | null): string {
  if (!email) return "Hello, visitor!";

  const user = getUserByEmail(email);
  if (!user) return "Hello, user not found!";

  const name = getUserName(user);
  return greetUser(name);
}

const greeting = processGreeting(email);
```

#### Benefits of early nullable handling

1. **Simpler functions**: Each function has a clear purpose and doesn't worry about nullable values.
2. **Better type inference**: TypeScript can infer more precise types, reducing the need for type annotations.
3. **Safer code**: Less likelihood of `TypeError: Cannot read property 'x' of null` errors.
4. **Better testability**: Functions with non-nullable inputs are easier to test.

#### Techniques for handling nullable values

1. **Early validation**:

```ts
function processData(data: string | null | undefined): void {
  if (data == null) {
    // Handle the nullable case
    return;
  }

  // From here on data is a string
  const upperCaseData = data.toUpperCase();
  // ...
}
```

2. **Default values**:

```ts
function processConfig(config: Config = defaultConfig): void {
  // We always work with a non-nullable value
  const timeout = config.timeout ?? 5000;
  // ...
}
```

3. **Pattern matching / discriminated unions**:

```ts
type Result<T> = { ok: true; value: T } | { ok: false; error: string };

function processResult<T>(result: Result<T>): void {
  if (!result.ok) {
    // Error handling
    console.error(result.error);
    return;
  }

  // TypeScript knows that result.value is present
  const value = result.value;
  // ...
}
```

This approach of handling nullable values early in the application flow and working with non-nullable types in most of the code leads to a more robust and easier to maintain system.

#### Nullables in React functional components

This principle is **especially important** in React functional components. React components often receive props that may be nullable, and it's easy to fall into patterns where these checks are repeated in multiple components or in multiple parts of the same component.

```tsx
// ❌ Bad: Propagating nullable props in nested components
type UserCardProps = {
  user: User | null;
};

const UserCard: React.FC<UserCardProps> = ({ user }) => {
  // Repetitive check
  if (!user) return <div>No user</div>;

  return (
    <div className="user-card">
      <UserHeader user={user} />
      <UserDetails user={user} />
      <UserActions user={user} />
    </div>
  );
};

const UserHeader: React.FC<UserCardProps> = ({ user }) => {
  // We have to check again
  if (!user) return null;

  return <h2>{user.name}</h2>;
};

const UserDetails: React.FC<UserCardProps> = ({ user }) => {
  // And again
  if (!user) return null;

  return (
    <div className="details">
      <p>Email: {user.email}</p>
      {/* ... */}
    </div>
  );
};
```

Better approach:

1. **Validation in the main component**:

```tsx
const UserProfile: React.FC<{ userId: string | null }> = ({ userId }) => {
  // Handle the nullable once
  if (!userId) return <div>Please select a user</div>;

  return <UserProfileContent userId={userId} />;
};

// This component always receives a non-nullable userId
const UserProfileContent: React.FC<{ userId: string }> = ({ userId }) => {
  // We don't need to check if userId is null
  const { data: user, loading, error } = useUser(userId);

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!user) return <NotFoundMessage />;

  // From here we know that user is present
  return (
    <div>
      <UserHeader name={user.name} avatar={user.avatar} />
      <UserDetails email={user.email} phone={user.phone} />
      {/* ... */}
    </div>
  );
};

// Components receive only the specific data they need
const UserHeader: React.FC<{ name: string; avatar: string }> = ({
  name,
  avatar,
}) => (
  <header>
    <img src={avatar} alt={name} />
    <h1>{name}</h1>
  </header>
);
```

2. **Using nullish coalescing operators and default values in props**:

```tsx
type UserAvatarProps = {
  user?: User;
  size?: "small" | "medium" | "large";
  fallbackImage?: string;
};

const UserAvatar: React.FC<UserAvatarProps> = ({
  user,
  size = "medium",
  fallbackImage = "/images/default-avatar.png",
}) => {
  // Using optional chaining with fallback
  const avatarUrl = user?.avatarUrl ?? fallbackImage;
  const userName = user?.name ?? "Unknown User";

  return (
    <img
      src={avatarUrl}
      alt={`Avatar of ${userName}`}
      className={`avatar-${size}`}
    />
  );
};
```
