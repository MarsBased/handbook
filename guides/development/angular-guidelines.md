# MarsBased Angular Style Guide

We follow the official and opionated [Angular coding style guide](https://angular.io/guide/styleguide) as the primary source of best practices and conventions.

<!-- vscode-markdown-toc -->
* 1. [Do's and Don'ts](#DosandDonts)
	* 1.1. [Logic in templates](#Logicintemplates)
	* 1.2. [Use index.ts](#Useindex.ts)
	* 1.3. [Use CDK Virtual Scroll](#UseCDKVirtualScroll)
	* 1.4. [Type Lazy modules](#TypeLazymodules)
	* 1.5. [Private methods](#Privatemethods)
	* 1.6. [Public methods](#Publicmethods)
	* 1.7. [View Methods](#ViewMethods)
	* 1.8. [Lifecycle Hooks](#LifecycleHooks)
	* 1.9. [HTML Attributes](#HTMLAttributes)
	* 1.10. [Empty Observables](#EmptyObservables)
	* 1.11. [HostListener/HostBinding decorators versus host metadata](#HostListenerHostBindingdecoratorsversushostmetadata)
  * 1.12. [Class members order](#ClassOrder)
* 2. [General project organization and architecture](#Generalprojectorganizationandarchitecture)
	* 2.1. [Project structure example](#Projectstructureexample)
* 3. [Describe most common patterns used to solve common problems](#Describemostcommonpatternsusedtosolvecommonproblems)
	* 3.1. [Lazy Pages](#LazyPages)
	* 3.2. [API Services](#APIServices)
		* 3.2.1. [Why?](#Why)
		* 3.2.2. [How?](#How)
	* 3.3. [Forms (Reactive Forms)](#FormsReactiveForms)
		* 3.3.1. [Simple FormBuilder sample](#SimpleFormBuildersample)
	* 3.4. [Smart and Dumb (Presentational) components](#SmartandDumbPresentationalcomponents)
	* 3.5. [State Management (with Akita)](#StateManagementwithAkita)
		* 3.5.1. [Global Entities](#GlobalEntities)
		* 3.5.2. [Specific module related logic](#Specificmodulerelatedlogic)
	* 3.6. [Testing](#Testing)
	* 3.7. [Memory Leaks](#MemoryLeaks)
	* 3.8. [I18N](#I18N)
* 4. [Libraries](#Libraries)
* 5. [Learning Resources](#LearningResources)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. <a name='DosandDonts'></a>Do's and Don'ts

Add and follow the official [MarsBased Angular ESLint configuration](https://github.com/MarsBased/marstyle/tree/master/angular), where most of do's and dont's are already defined.

###  1.1. <a name='Logicintemplates'></a>Logic in templates

Don't put logic in templates. 

```html
<!-- bad  (component's logic, not HTML) -->
<div *ngIf="user.active && !user.expired">
  ...
</div>


<!-- good -->
<div *ngIf="isUserVisible">
  ...
</div>
```

```ts
export class MyComponent {
  ...

  get isUserVisible(): boolean {
    return this.user.active && !this.user.expired;
  }
  ...
}
```

###  1.2. <a name='Useindex.ts'></a>Use index.ts

Do use index.ts when you see the opportunity. The model directory of a module is a good candidate. It decreases the number and size of imports in components and services.

Export models from the /models directory:

```ts
export * from './user.model';
export * from './product.model';

```

Import them where you need them:

```ts
import { UserModel, ProductModel } from '../models';
```

###  1.3. <a name='UseCDKVirtualScroll'></a>Use CDK Virtual Scroll

Do use [CDK Virtual Scroll](https://material.angular.io/cdk/scrolling/overview) when showing huge list of elements. It improves performance **drastically**. 

###  1.4. <a name='TypeLazymodules'></a>Type Lazy modules

Do Type lazy modules with `async` and `Promise` types.

```ts
{
  path: 'lazy-module',
  pathMatch: 'full',
  loadChildren: async (): Promise<LazyModule> =>
    (await import('./modules/lazy-module/lazy-module.module')).LazyModule,
}
```

###  1.5. <a name='Privatemethods'></a>Private methods

Do mark the visibility of private methods when are called only from inside the class.

###  1.6. <a name='Publicmethods'></a>Public methods

Do not mark the visibility of public methods, as it's by default.

```ts
// bad (public by default)
public isUserVisible(): boolean {
  return this.user.active && !this.user.expired;
}

// good
isUserVisible(): boolean {
  return this.user.active && !this.user.expired;
}
```

###  1.7. <a name='ViewMethods'></a>View Methods

Do not mark as private methods called from the component's view (public).

###  1.8. <a name='LifecycleHooks'></a>Lifecycle Hooks

- Add hooks just after the class constructor.
- Add their interfaces to the class.
- Add hooks in the order they execute.
- Encapsulate logic inside private methods and call them from the hooks.

```ts
export class MyComponent implements OnInit, OnDestroy {

  constructor() {  }

  ngOnInit(): void {
    this.initData();
  }

  ngOnDestroy(): void {
    this.freeResources();
  }

  private initData(): void {
    ...
  }

  private freeResources(): void {
    ...
  }
}
```

###  1.9. <a name='HTMLAttributes'></a>HTML Attributes

Do sort the HTML tag attributes.

- With multiple attributes, one attribute per line.
- With multiple attributes, the closing tag has to be written on the next line.
- Sort attributes
  1. Structural
  2. Angular data binding properties and events.
  3. Dynamic Properties
  4. Animations
  5. Static and native HTML properties.


```html
<!-- bad (hard to follow) -->
  <div 
    class="user__container"
    @fadeIn
    [user]="user"
    (refresh)="onUserRefresh()"
    [title]="user.name"
    *ngIf="isVisible"
  >
   ...
  </>

<!-- good -->
  <div 
    *ngIf="isVisible"
    [user]="user"
    (refresh)="onUserRefresh()"
    [title]="user.name"
    @fadeIn
    class="user__container"
  >
   ...
  </>
```

###  1.10. <a name='EmptyObservables'></a>Empty Observables

Do prefer the EMPTY variable over the of operator when generating an empty observable.

```ts
// bad (Don't use `of()` operator:)
const checkActionDispatched = !isActionDispatched ? 
  dispatch(new Action()) : 
  of();

// good
import { EMPTY } from 'rxjs';

const checkActionDispatched = !isActionDispatched ? 
  dispatch(new Action()) : 
  EMPTY;
``` 

###  1.11. <a name='HostListenerHostBindingdecoratorsversushostmetadata'></a>HostListener/HostBinding decorators versus host metadata

Do prefer the @HostListener and @HostBinding to the host property of the @Directive and @Component decorators. Refer to the [Angular Style Guide](https://angular.io/guide/styleguide#style-06-03) for more details.

### 1.12. <a name='ClassOrder'></a> Class members order

Do sort class members as follow:

1. Inputs/Outputs
2. ViewChilds
3. Public properties
4. Private properties
5. Class accessors
6. Constructor
7. Angular's lifecycle hooks
8. Event methods
9. Public methods
10. Private methods

```ts
const MY_LIST = [{id: 1, value: 'option 1'}, {id: 2, value: 'option 2'}]
@Component({
   templateUrl: './my-component.component.html',
   selector: 'my-component',
})
export class MyComponent {
  @Input() categories: Category[];

  @Output() disassociate = new EventEmitter<Category>();

  @ViewChild(FormComponent) formCpm: FormComponent;

  user: User;
  category: Category;
  private selectedUser: User;
  private selectedCategory: Category;
  readonly comboList = MY_LIST;

  get isActive(): boolean {
    return this.user.active;
  }

  constructor() { }

  ngOnInit(): void {
    this.initData();
  }

  submit(): void {
    ...
  }

  private initData(): void {
    ...
  }
}
```

##  2. <a name='Generalprojectorganizationandarchitecture'></a>General project organization and architecture

Follow the [Angular Style Guide](https://angular.io/guide/styleguide#style-06-03) to name files and directories. Additionally:

- Routed modules under the /pages directory.
- Page components under the routed module directory /pages/\*/.
- Regular components under the routed module directory /pages/\*/components.
- Standalone modules under the /modules directory.
- State management files under the /state directory.
- Helpers, utils and custom libraries under the /libs directory.

###  2.1. <a name='Projectstructureexample'></a>Project structure example

```
cypress/                              # end-to-end tests
src/app/
|- pages/                            # routed modules
  |- admin/                           # routed /admin module
    |- components/                    # admin's modules
      |- avatar/
      |- navbar/
    |- pages/                        # routed modules under /admin
      |- planets/                     # routed /admin/planets module
    |- models/
    |- services/
    |- state/
    |- admin-routing.module.ts        # admin route definition
    |- admin.component.html           # admin component page
    |- admin.component.spec.ts        # admin component page
    |- admin.component.ts             # admin component page
    |- admin.module.ts                # admin module
  |- auth/
|- modules/                           # standalone modules (configuration, utils)
|- shared/                            # shared modules used from child routes
|- state/                             # state files (store, query, state)
|- libs/                              # internal libraries directory
|- models/
|- services/
|- guards/
|- interceptors/
|- app-routing.module.ts              # root component page
|- app.component.html                 # root component page
|- app.component.spec.ts              # root component page
|- app.component.ts                   # root component page
|- app.module.ts                      # root module
```

##  3. <a name='Describemostcommonpatternsusedtosolvecommonproblems'></a>Describe most common patterns used to solve common problems

###  3.1. <a name='LazyPages'></a>Lazy Pages

Lazy load every page always, placing routed modules under the /pages directory. This way, the architecture and the tree folder mirror the URL map presented to the user.

E.g. `http://sample.com/admin/planets` can be accessed from `src/app/pages/admin/pages/planets`.

Check the next guides for further information about lazy loading and feature modules:

- [Angular Feature Modules](https://angular.io/guide/feature-modules)
- [Angular Lazy Loading](https://angular.io/guide/lazy-loading-ngmodules)

###  3.2. <a name='APIServices'></a>API Services

We define a clear separation between API Services that retrieve data, usually from an API endpoint, from the rest of the services with business logic.

####  3.2.1. <a name='Why'></a>Why?

Better control of the data flow, what happens if a request fails? should I keep the current store? should I empty the store? are we writing code only for success responses? That depends on the context, if we couple API calls and other logic we lose control of the data flow. We'll find ourselves writing the same API calls with some modifications for different situations.

- **Reusable**. We often call the same endpoint from multiple parts of the app for different purposes, if the API service is not coupled with extra code we can reuse it easily.
- **Flexible**. We don't need to store everything we retrieve from the API, and sometimes, we want to avoid it (like large data sets or blobs). Also, we could save/process the data in different ways depending on the context. Sometimes we'll want to cache data from responses, sometimes not. When retrieving an entity, we don't want to save it always in the same store, it could be a `selectedEntity`, `oldEntity`, `newEntity`, `originEntity`, etc... you get the idea.
- **Independent**. API services doesn't have dependencies.
  In short, I think this could help to avoid ambiguous rules when writing services, leading to a more uniform codebase.

####  3.2.2. <a name='How'></a>How?

```ts
@Injectable()
export class UsersService {
  constructor(private http: HttpClient) {}

  getAll() {
    return this.http
      .get<User>(``)
      .map((response: ResponseModel<User>) => response.data);
  }
}
```

We name this services adding the `api` suffix `users.api.service.ts`

```ts
@Injectable()
export class UsersApiService { ... }
```

We can keep regular mappings inside this service, as they extract the key data we want, saving some code inside components.

When saving an entity to a store, we do it from a regular service, where we have our business logic.

```ts
@Injectable()
export class UsersAdminService {
  constructor(
    private usersApiService: UsersApiService,
    private usersStore: UsersStore
  ) {}

  getUsers() {
    return this.usersApiService
      .getAll()
      .pipe(tap((response) => this.usersStore.set(response)));
  }
}
```

###  3.3. <a name='FormsReactiveForms'></a>Forms (Reactive Forms)

The next articles are a good source to understand how to implement reactive forms in Angular:

- [Reactive Forms](https://angular.io/guide/reactive-forms).
- [A thorough exploration of Angular Forms](https://indepth.dev/posts/1143/a-thorough-exploration-of-angular-forms)
- [Angular Reactive Forms Tips and Tricks](https://netbasal.com/angular-reactive-forms-tips-and-tricks-bb0c85400b58)

####  3.3.1. <a name='SimpleFormBuildersample'></a>Simple FormBuilder sample

Inject FormBuilder service to define forms fields and validations inside a component class.

```ts
  import { FormBuilder } from '@angular/forms';

  ...

  form: FormGroup;

  ...

  constructor(private fb: FormBuilder) {}

  ...
```

Often, we create the form instance inside the constructor or when the OnInit hook executes:

```ts

private initForm(): void {
  this.form = this.fb.group({
    name: ['', Validators.required],
    phone: ['']
    password: ['', [Validators.required,  Validators.pattern('^[a-z]*$')]]
  });
}

```

After, we register the created form for the HTML container tag, and attach every form field with every input or control.

```html
<form [formGroup]="form">
  <input formControlName="name" type="text" />
</form>
```

###  3.4. <a name='SmartandDumbPresentationalcomponents'></a>Smart and Dumb (Presentational) components

The only goal of a presentational component is to keep the UI logic isolated. It doesn't have access to injected business services. It communicates using @Input and @Output data flows.Presentational components communicate using Input and Output only.

A smart component, or smart container, injects business services and keeps a more complex state. Its goal is to orchestrate the communication and behaviour between data services and presentational components. Smart components communicate to the rest of the app using injected services, Input an Outputs.

Having a separation between smart and presentational components adds the advantages:

- Easier to write and more focused tests.
- Isolated UI state.
- Better component reusability.

Check the [Angular University](https://blog.angular-university.io/angular-2-smart-components-vs-presentation-components-whats-the-difference-when-to-use-each-and-why/) article about smart and presentational components for a detailed explanation.

###  3.5. <a name='StateManagementwithAkita'></a>State Management (with Akita)

Akita offers, basically, two JS classes to interact with, the store for adding/modify objects and the query for consulting it, and that's all, no more Actions, Reducers nor Effects.

Akita's decoupled components: All Akita store management could be done (and its fully recommended) throw a service so components are totally detached from it, an async method that interacts with the store remains as an async method for the component and could react to fulfillment if needed (not as flux-like store actions that are "flattened")

####  3.5.1. <a name='GlobalEntities'></a>Global Entities

It's so recommended exposing globally all entities obtained from the backend and that's the perfect use-case for the entity store and entity query , both could be imported in a root provided (or shared module imported by) service, related with 💥 Angular API Services - Development and totally in the same page, could be something like:

|- app/
|- api/
|- users-api.service.ts
|- stores/
|- users/
|- users.state-service.ts
|- users.store.ts
|- users.query.ts

- `users-api.service.ts`: Expose methods for obtaining data from the backend.
- `users.store.ts`: Defines users store. Docs
- `users.query.ts`: Offers different methods for exposing store objects. Contrary to Akita recommendations, we think could be a better approach creating composed queries in users-state.service instead of here and access to the query object only throw the service. Docs
  users.state-service.ts: Acts as facade for any other service that want to interact with users entities, uses users-api.service to obtain users related data, fills/modifies store throw users.store and creates and exposes queries using users.query. Docs

####  3.5.2. <a name='Specificmodulerelatedlogic'></a>Specific module related logic

For coding the logic related to a specific feature all state could be imported only in the related module, this case Entity store/query doesn't make sense so normal store and query objects could be used.

|- users-section-module
|- state/
|- users-section-state.service.ts
|- users-section.store.ts
|- users-section.query.ts

- `users-section.store.ts`: Defines users-section store. Docs
- `users-section.query.ts`: Offers different methods for exposing store objects. Contrary to Akita recommendations, we think could be a better approach creating composed queries in users-section-state.service instead of here and access to the query object only throw the service. Docs
- `users-section-state.service.ts`: Holds all users-section related logic, interacts with users-section-store for filling/modifying objects, with users-section.query to expose them on demand and with api related services (users.state-service.ts) for obtaining backend data and modify/consult related store. Docs

###  3.6. <a name='Testing'></a>Testing

Favor end-to-end-testing over components test.

- End-to-end: [Cypress](https://www.cypress.io/)
- Components: [Spectator](https://github.com/ngneat/spectator) and [Jest](https://jestjs.io/)
- Unit JS tests: [Jest](https://jestjs.io/)

###  3.7. <a name='MemoryLeaks'></a>Memory Leaks

Consider and prevent memory leaks from subscriptions in components.

Read [Dealing with memory leaks](https://marsbased.com/es/blog/2018/06/18/dealing-with-memory-leaks-reactivex/) to understand better when this problem arises.

To avoid these leaks, we use the [NgNeat Until Destroy lib](https://github.com/ngneat/until-destroy) that adds support for unsubscribing automatically from subscriptions when a component is destroyed.


```ts
import { UntilDestroy, untilDestroyed } from '@ngneat/until-destroy';

@UntilDestroy()
@Component({})
export class InboxComponent {
  ngOnInit() {
    interval(1000)
      .pipe(untilDestroyed(this))
      .subscribe();
  }
}
```

The order of decorators is important, make sure to put @UntilDestroy() before the @Component() decorator.

###  3.8. <a name='I18N'></a>I18N

For simplicity and ease of use, we don't use the translation services that Angular has in its core.

Use [Transloco](https://github.com/ngneat/transloco).

##  4. <a name='Libraries'></a>Libraries

- [Transloco](https://github.com/ngneat/transloco). Translation library for Angular.
- [NgNeat Until Destroy lib](https://github.com/ngneat/until-destroy). Avoid memory leaks in components.
- [Cypress](https://www.cypress.io/). E2E tests.
- [Spectator](https://github.com/ngneat/spectator). Angular test's helpers.
- [Jest](https://jestjs.io/). General purpose JS testing.
- [ESLint](https://eslint.org/). JS Linter
- [Date-fns](https://date-fns.org/). Provides functions to manipulate dates.
- [Angular Material](https://material.angular.io/). A collection of components and other Angular resources to build the UI.
- [NgBootstrap](https://ng-bootstrap.github.io/#/home). Bootstrap library ported to Angular components.

##  5. <a name='LearningResources'></a>Learning Resources

Our articles:

- [Comparing the Three Angular View Encapsulation Methods](https://marsbased.com/blog/2019/06/17/angular-view-encapsulation/)
- [Changing Detection Strategy in Angular](https://marsbased.com/blog/2019/05/13/change-detection-strategy-angular/)

Other resources:

- [TypeScript documentation](https://www.typescriptlang.org/docs/home.html)
- [Angular architecture overview](https://angular.io/guide/architecture)
- [Angular official tutorial](https://angular.io/tutorial)
- [RXJS official documentation](https://rxjs-dev.firebaseapp.com/)
- [Angular RxJS tutorial](https://angular.io/guide/rx-library)
- [Alligator Angular's courses](https://alligator.io/angular/)
- [Angular in Depth blog](https://indepth.dev/angular) 
- [Reddit Angular 2+](https://www.reddit.com/r/Angular2/) 
- [Angular University](https://blog.angular-university.io)
- [Angular cheatsheet](https://angular.io/guide/cheatsheet)
- [Egghead](https://egghead.io/courses/for/angular)
- [Adventures in Angular](https://devchat.tv/adv-in-angular/)
- [Angular Awesome resource list](https://github.com/PatrickJS/awesome-angular)

These are our reference resources. Still, a project often needs extra libraries. Before adding a new library, it must be approved by the project's tech lead.

Are you missing any resource or interesting article on this list? Feel free to suggest additional useful resources by creating a PR to let us know!
