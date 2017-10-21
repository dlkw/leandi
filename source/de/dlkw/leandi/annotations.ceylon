import ceylon.language.meta.declaration {
    ValueDeclaration
}
shared final annotation class VariantAnnotation(shared String name)
        satisfies OptionalAnnotation<VariantAnnotation, ValueDeclaration>
{}

shared annotation VariantAnnotation variant(String name)
{
    return VariantAnnotation(name);
}