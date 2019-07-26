package tools.vitruv.dsls.mappings.generator.utils

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.common.types.JvmDeclaredType
import org.eclipse.xtext.common.types.JvmMember
import tools.vitruv.dsls.mirbase.mirBase.MetaclassFeatureReference
import tools.vitruv.dsls.reactions.builder.FluentRoutineBuilder.RoutineTypeProvider

class XBaseMethodFinder {

	private final static String PACKAGE_OPTIONAL = 'java.util.Optional'
	private final static String PACKAGE_OBJECT = 'org.eclipse.xtext.xbase.lib.ObjectExtensions'
	private final static String PACKAGE_BOOLEAN = 'org.eclipse.xtext.xbase.lib.BooleanExtensions'
	private final static String PACKAGE_ITERATOR = 'org.eclipse.xtext.xbase.lib.IteratorExtensions'

	public static def optionalIsPresent(RoutineTypeProvider typeProvider) {
		typeProvider.findXbaseMethod(PACKAGE_OPTIONAL, 'isPresent')
	}

	public static def optionalGet(RoutineTypeProvider typeProvider) {
		typeProvider.findXbaseMethod(PACKAGE_OPTIONAL, 'get')
	}

	// should find the correct filter method because it is listed first in the class
	public static def listFilter(RoutineTypeProvider typeProvider) {
		typeProvider.findXbaseMethod(PACKAGE_ITERATOR, 'filter')
	}

	// should find first add
	public static def collectionAdd(RoutineTypeProvider typeProvider) {
		typeProvider.findXbaseMethod(PACKAGE_ITERATOR, 'operator_add')
	}

	public static def and(RoutineTypeProvider typeProvider) {
		typeProvider.findXbaseMethod(PACKAGE_BOOLEAN, 'operator_and')
	}

	public static def or(RoutineTypeProvider typeProvider) {
		typeProvider.findXbaseMethod(PACKAGE_BOOLEAN, 'operator_or')
	}

	public static def tripleEquals(RoutineTypeProvider typeProvider) {
		typeProvider.findXbaseMethod(PACKAGE_OBJECT, 'operator_tripleEquals')
	}

	public static def tripleNotEquals(RoutineTypeProvider typeProvider) {
		typeProvider.findXbaseMethod(PACKAGE_OBJECT, 'operator_tripleNotEquals')
	}

	public static def findXbaseMethod(RoutineTypeProvider typeProvider, String pkg, String method) {
		(typeProvider.findTypeByName(pkg) as JvmDeclaredType).members.findFirst [
			it.simpleName == method
		]
	}

	public static def findMetaclassMethodGetter(RoutineTypeProvider typeProvider, EClass metaclass,
		EStructuralFeature feature) throws MethodNotFoundException {
		val name = '''get«feature.name.toFirstUpper»«IF feature.many»s«ENDIF»'''
		typeProvider.findMetaclassMethod(metaclass, name)
	}

	public static def findMetaclassMethodSetter(RoutineTypeProvider typeProvider, EClass metaclass,
		EStructuralFeature feature) throws MethodNotFoundException {
		val name = '''set«feature.name.toFirstUpper»«IF feature.many»s«ENDIF»'''
		typeProvider.findMetaclassMethod(metaclass, name)
	}

	public static def findMetaclassMethodGetter(RoutineTypeProvider typeProvider,
		MetaclassFeatureReference ref) throws MethodNotFoundException {
		typeProvider.findMetaclassMethodGetter(ref.metaclass, ref.feature)
	}

	public static def findMetaclassMethod(RoutineTypeProvider typeProvider, EClass metaclass,
		String method) throws MethodNotFoundException {
		val package = metaclass.instanceTypeName
		val type = typeProvider.findTypeByName(package) as JvmDeclaredType
		findMethod(type, type, method)
	}

	private static def JvmMember findMethod(JvmDeclaredType type, JvmDeclaredType originalType,
		String member) throws MethodNotFoundException {
		var method = type.members.findFirst[it.simpleName == member]
		if (method !== null) {
			return method
		}
		for (superTypeRef : type.superTypes) {
			val superType = superTypeRef.type
			if (superType instanceof JvmDeclaredType) {
				method = findMethod(superType, originalType, member)
				if (method !== null) {
					return method
				}
			}
		}
		throw new MethodNotFoundException('''Could not find method «member» in type «originalType»''')
	}

	private static class MethodNotFoundException extends Exception {
		new(String msg) {
			super(msg)
		}
	}

}
