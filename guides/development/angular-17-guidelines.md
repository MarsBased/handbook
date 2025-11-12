# MarsBased Angular 17 Style Guide

### 🚧 This guide is focused on Angular 17, for older versions see [here](./angular-guidelines.md) 🚧

We follow the official and opinionated [Angular coding style guide](https://angular.dev/style-guide) as the primary source of best practices and conventions.

## Standalone Components

In the latest versions of Angular, it is recommended to use standalone components. These are components that do not have a direct relationship with other components and can be used independently. Previously, all elements were organized in modules, and using an element from a module meant loading the entire module.

Now, with standalone components, each component is used individually, which improves application load time and performance.

## Single Responsibility Services with State Management

In Angular, services should adhere to the Single Responsibility Principle, meaning each service should focus on a specific domain or functionality. By doing so, services become easier to maintain, test, and reuse.

Additionally, these services should manage their state using signals, allowing components to subscribe to state changes efficiently. Signals provide a reactive way to handle state, enabling components to subscribe to state changes and automatically update when the state changes.

## Smart and Dumb (Presentational) components

The only goal of a presentational component is to keep the UI logic isolated. It doesn't have access to injected business services. It communicates using @Input and @Output data flows.Presentational components communicate using Input and Output only.

A smart component, or smart container, injects business services and keeps a more complex state. Its goal is to orchestrate the communication and behaviour between data services and presentational components. Smart components communicate to the rest of the app using injected services, Input an Outputs.

Having a separation between smart and presentational components adds the advantages:

- Easier to write and more focused tests.
- Isolated UI state.
- Better component reusability.

## Structuring Application Architecture Using Routes

In Angular, organizing the application's architecture by following the routes can enhance readability, maintainability, and scalability. Similar to other frameworks, using a route-based folder structure helps engineers quickly locate components associated with specific routes, improving overall development efficiency.

### Folder Structure

Within the src directory, create a routes folder that mirrors the application's routes. Each route should have its own folder containing all related components, services, etc. This structure helps keep the project organized and makes it easier to manage and scale the application as it grows.

Here's an example of how to structure the folders for an application with a users route:

```
src/
  app/
    routes/
          users/
            # users components
```

## State Interface

Maintaining common interface components, such as modals, popups, or loading spinners, in a parent component common to the entire application is a recommended practice. This approach helps in managing the application's UI state efficiently and ensures a consistent look and feel across the application.

By centralizing the management of common interface components in a parent component, you can:

- Reduce Redundancy: Avoid duplicating code for common UI elements across multiple child components.
- Ensure Consistency: Maintain a uniform appearance and behavior for UI elements, ensuring a consistent user experience.
- Simplify Maintenance: Make it easier to update and manage UI components, as changes are made in a single place rather than across multiple components.

## Input signals

Components in Angular should receive input data through inputs, specifically as input signals. This practice becomes particularly advantageous when writing code in a reactive style using signals.

### Advantages of Using Input Signals

#### Reactive Style

By using signals as inputs, all the component's input data become signals themselves. This allows for easily deriving computed signals from them and defining effects that react to input changes. In other words, it facilitates writing components in a reactive, signal-based style.

#### Data Transformation

The parent component does not need to transform or update the input data. This responsibility falls on the child component, which simplifies the logic in the parent component and makes it easier to reuse and test the child components.

#### Change Detection

Using signals as inputs improves the component's change detection. Angular can detect changes more efficiently because signals allow for more precise tracking of state modifications.

#### State Derivation

Signals enable more effective derivation of the input state. For example, you can create computed signals that depend on the inputs and automatically update the component's state when the inputs change.

A more comprehensive article on signals in Angular can be found [here](https://blog.angular-university.io/angular-signal-inputs/).
