# leandi
A lean dependency injector written in/for the Ceylon language, supporting both the JVM and the JS backends.

It is inspired by the DI container of [Apache Cayenne](http://cayenne.apache.org/docs/4.0/cayenne-guide/customizing-cayenne-runtime.html#depdendency-injection-container). I tried to adapt it to more ceylonesque idioms. The original is likely much more
stable.

## Supported
* Default constructor parameter or class parameter argument injection
* Definition of injection binding via Ceylon program code
* Interfaces or classes can be bound to classes implementing them
* Binding can use classes or instances as binding definition
* Cycle detection of dependencies (rejection bindings with cycles)
* Two scopes: singleton (default) or noScope
* Scope definition extendable
* The same class or interface can be bound to different implementations using variants (although non-transitively)


## Not supported
* Injected classes without parameter list or default constructor
* Value injection
* Magic stuff to solve cycles using proxy generation
* Class scanning for injectable/injected classes
* Transitive variants (seems to be a can of worms...)

## Usage

```ceylon
import de.dlkw.leandi {
    Binder,
    singleton,
    createInjector
}


shared void run()
{
    value diModule = object satisfies Module
    {
        shared actual void bindings(Binder binder)
        {
            binder.bind<IA>(`IA`).to(`A`, singleton);
            binder.bind<IB>(`IB`).to(`B`, singleton);
            binder.bind<IB>(`IB`, "j").to(`B`, singleton);
            binder.bind<IC>(`IC`).to(`C`, singleton);
        }
    };

    value injector2 = createInjector(diModule);

    value c = injector.instance(`IC`);
    print(c);
    value a = injector.instance(`IA`);
    print(a);
    value b = injector.instance(`IB`);
    print(b);
    value bj = injector.instance(`IB`, "j");
    print(bj);
}

interface IA{}
class A satisfies IA
{
    shared new (){print("cre A");}
}

interface IB{}
class B(IA a) satisfies IB
{
    print("cre B");
}

interface IC{}
class C(IB b) satisfies IC
{
    print("cre C");
}
```
