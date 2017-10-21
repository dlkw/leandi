import de.dlkw.leandi {
    Binder,
    singleton,
    createInjector
}


shared void run()
{
    value inj = createInjector((binder)
    {
        binder.bind<IA>(`IA`).to(`A`, singleton);
        binder.bind<IB>(`IB`).to(`B`, singleton);
        binder.bind<IB>(`IB`, "j").to(`B`, singleton);
        binder.rebind<IC>(`IC`).to(`C`, singleton);
    });

    value c = inj.instance(`IC`);
    print(c);
    value a = inj.instance(`IA`);
    print(a);
    value b = inj.instance(`IB`);
    print(b);
    value bj = inj.instance(`IB`, "j");
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
