import ceylon.language.meta.model {
    ClassOrInterface,
    CallableConstructor,
    Class
}


class ConstructorProvider<Instance>(Class<Instance> implementingClass)
        satisfies Provider<Instance>
        given Instance satisfies Object
{
    CallableConstructor<Instance> usedConstructor;
    if (exists defaultConstructor = implementingClass.defaultConstructor) {
        usedConstructor = defaultConstructor;
    }
    else {
        throw BindingException("Only implemented for classes with a parameter list or default constructor");
    }
    
    shared actual Instance provide(Injector injector)
    {
        value args = usedConstructor.parameterTypes.map((parameterType)
        {
            assert (is ClassOrInterface<Object> parameterType);
            // we don't support "transitive variants", it's a Can of Worms
            return injector.instance(parameterType, null);
        });
        return usedConstructor.apply(*args);
    }
}

class InstanceProvider<Instance>(Instance instance)
        satisfies Provider<Instance>
        given Instance satisfies Object
{
    shared actual Instance provide(Injector injector) => instance;
}
