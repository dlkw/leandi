"A dependency injection binding module gathers several bindings in one place. You
 create an injector by passing one or several modules, each containing the bindings
 for some architectural domain of your project."
shared interface Module
{
    shared formal void bindings(Binder binder);
}