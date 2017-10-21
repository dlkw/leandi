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


shared interface Scope
{
    shared formal Provider<Instance> scoped<K, Instance>(ClassOrInterface<K> key, Provider<Instance> provider, String? variant = null)
            given K satisfies Object
            given Instance satisfies K;
}

"A `Scope` that does not store instances, effectively providing a new instance each time."
shared object noScope satisfies Scope
{
    shared actual Provider<Instance> scoped<K, Instance>(ClassOrInterface<K> ignored, Provider<Instance> provider, String? variant)
            given K satisfies Object
            given Instance satisfies K => provider;
}


native shared object singleton satisfies Scope
{
    native shared actual Provider<Instance> scoped<K, Instance>(ClassOrInterface<K> key, Provider<Instance> provider, String? variant)
            given K satisfies Object
            given Instance satisfies K;

}

"A `Scope` that stores an instance forever so that only one instance will be created."
native("jvm") shared object singleton satisfies Scope
{
    native("jvm") shared actual Provider<Instance> scoped<K, Instance>(ClassOrInterface<K> key, Provider<Instance> provider, String? variant)
            given K satisfies Object
            given Instance satisfies K =>
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
    native("js") shared actual Provider<Instance> scoped<K, Instance>(ClassOrInterface<K> key, Provider<Instance> provider, String? variant)
            given K satisfies Object
            given Instance satisfies K =>
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
