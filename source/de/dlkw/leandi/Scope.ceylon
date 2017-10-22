import ceylon.language.meta.model {
    ClassOrInterface
}

import java.lang {
    synchronized
}
import java.util.concurrent {
    ConcurrentHashMap
}
import ceylon.collection {
    HashMap
}


"Provides an instance of class `Instance`, using an `Injector` for dependencies."
shared interface Provider<out Instance>
        given Instance satisfies Object
{
    shared formal Instance provide(Injector injector);
}

"A Scope determines when to create new instances of a bound interface and variant, and when to use already existing ones. It stores
 created instances in some implementation specific storage and retrieves them from there instead of
 creating a new instance."
shared interface Scope
{
    shared formal Provider<Instance> scoped<Iface, Instance>(ClassOrInterface<Iface> iface, Provider<Instance> provider, String? variant = null)
            given Iface satisfies Object
            given Instance satisfies Iface;
}

"A `Scope` that does not store instances, effectively providing a new instance each time."
shared object noScope satisfies Scope
{
    shared actual Provider<Instance> scoped<Iface, Instance>(ClassOrInterface<Iface> ignored, Provider<Instance> provider, String? variant)
            given Iface satisfies Object
            given Instance satisfies Iface => provider;
}


"A `Scope` that stores an instance forever so that only one instance will be created."
native shared object singleton satisfies Scope
{
    native shared actual Provider<Instance> scoped<Iface, Instance>(ClassOrInterface<Iface> key, Provider<Instance> provider, String? variant)
            given Iface satisfies Object
            given Instance satisfies Iface;

}

native("jvm") shared object singleton satisfies Scope
{
    native("jvm") shared actual Provider<Instance> scoped<Iface, Instance>(ClassOrInterface<Iface> key, Provider<Instance> provider, String? variant)
            given Iface satisfies Object
            given Instance satisfies Iface =>
        object satisfies Provider<Instance>
        {
            value variantInstances = ConcurrentHashMap<String, Instance>();
            variable Instance? instance = null;

            shared actual Instance provide(Injector injector)
            {
                synchronized Instance synchronizedProvide(Injector injector)
                {
                    if (exists i = instance) {
                        return i;
                    }
                    return instance = provider.provide(injector);
                }
    
                if (exists variant) {
                    return variantInstances.computeIfAbsent(variant, (v) => provider.provide(injector));
                }
                
                return synchronizedProvide(injector);
            }
        };
}

native("js") shared object singleton satisfies Scope
{
    native("js") shared actual Provider<Instance> scoped<Iface, Instance>(ClassOrInterface<Iface> key, Provider<Instance> provider, String? variant)
            given Iface satisfies Object
            given Instance satisfies Iface =>
        object satisfies Provider<Instance>
        {
            value variantInstances = HashMap<String, Instance>();
            variable Instance? instance = null;
            
            shared actual Instance provide(Injector injector)
            {
                if (exists variant) {
                    // Would be nice if Ceylon MutableMap had computeIfAbsent method!
                    value storedInstance = variantInstances[variant];
                    if (exists storedInstance) {
                         return storedInstance;
                    }
                    value newInstance = provider.provide(injector);
                    variantInstances[variant] = newInstance;
                    return newInstance;
                }
                
                if (exists i = instance) {
                    return i;
                }
                return instance = provider.provide(injector);
            }
        };
}
