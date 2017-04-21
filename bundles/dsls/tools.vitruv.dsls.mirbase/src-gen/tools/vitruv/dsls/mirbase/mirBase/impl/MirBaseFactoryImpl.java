/**
 * generated by Xtext 2.10.0
 */
package tools.vitruv.dsls.mirbase.mirBase.impl;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;

import org.eclipse.emf.ecore.impl.EFactoryImpl;

import org.eclipse.emf.ecore.plugin.EcorePlugin;

import tools.vitruv.dsls.mirbase.mirBase.*;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model <b>Factory</b>.
 * <!-- end-user-doc -->
 * @generated
 */
public class MirBaseFactoryImpl extends EFactoryImpl implements MirBaseFactory
{
  /**
   * Creates the default factory implementation.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public static MirBaseFactory init()
  {
    try
    {
      MirBaseFactory theMirBaseFactory = (MirBaseFactory)EPackage.Registry.INSTANCE.getEFactory(MirBasePackage.eNS_URI);
      if (theMirBaseFactory != null)
      {
        return theMirBaseFactory;
      }
    }
    catch (Exception exception)
    {
      EcorePlugin.INSTANCE.log(exception);
    }
    return new MirBaseFactoryImpl();
  }

  /**
   * Creates an instance of the factory.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public MirBaseFactoryImpl()
  {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public EObject create(EClass eClass)
  {
    switch (eClass.getClassifierID())
    {
      case MirBasePackage.DUMMY_ENTRY_RULE: return createDummyEntryRule();
      case MirBasePackage.MIR_BASE_FILE: return createMirBaseFile();
      case MirBasePackage.METAMODEL_IMPORT: return createMetamodelImport();
      case MirBasePackage.NAMED_JAVA_ELEMENT: return createNamedJavaElement();
      case MirBasePackage.METACLASS_REFERENCE: return createMetaclassReference();
      case MirBasePackage.NAMED_METACLASS_REFERENCE: return createNamedMetaclassReference();
      case MirBasePackage.METACLASS_FEATURE_REFERENCE: return createMetaclassFeatureReference();
      case MirBasePackage.METACLASS_EATTRIBUTE_REFERENCE: return createMetaclassEAttributeReference();
      case MirBasePackage.METACLASS_EREFERENCE_REFERENCE: return createMetaclassEReferenceReference();
      case MirBasePackage.METAMODEL_REFERENCE: return createMetamodelReference();
      case MirBasePackage.DOMAIN_REFERENCE: return createDomainReference();
      default:
        throw new IllegalArgumentException("The class '" + eClass.getName() + "' is not a valid classifier");
    }
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public DummyEntryRule createDummyEntryRule()
  {
    DummyEntryRuleImpl dummyEntryRule = new DummyEntryRuleImpl();
    return dummyEntryRule;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public MirBaseFile createMirBaseFile()
  {
    MirBaseFileImpl mirBaseFile = new MirBaseFileImpl();
    return mirBaseFile;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public MetamodelImport createMetamodelImport()
  {
    MetamodelImportImpl metamodelImport = new MetamodelImportImpl();
    return metamodelImport;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public NamedJavaElement createNamedJavaElement()
  {
    NamedJavaElementImpl namedJavaElement = new NamedJavaElementImpl();
    return namedJavaElement;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public MetaclassReference createMetaclassReference()
  {
    MetaclassReferenceImpl metaclassReference = new MetaclassReferenceImpl();
    return metaclassReference;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public NamedMetaclassReference createNamedMetaclassReference()
  {
    NamedMetaclassReferenceImpl namedMetaclassReference = new NamedMetaclassReferenceImpl();
    return namedMetaclassReference;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public MetaclassFeatureReference createMetaclassFeatureReference()
  {
    MetaclassFeatureReferenceImpl metaclassFeatureReference = new MetaclassFeatureReferenceImpl();
    return metaclassFeatureReference;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public MetaclassEAttributeReference createMetaclassEAttributeReference()
  {
    MetaclassEAttributeReferenceImpl metaclassEAttributeReference = new MetaclassEAttributeReferenceImpl();
    return metaclassEAttributeReference;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public MetaclassEReferenceReference createMetaclassEReferenceReference()
  {
    MetaclassEReferenceReferenceImpl metaclassEReferenceReference = new MetaclassEReferenceReferenceImpl();
    return metaclassEReferenceReference;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public MetamodelReference createMetamodelReference()
  {
    MetamodelReferenceImpl metamodelReference = new MetamodelReferenceImpl();
    return metamodelReference;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public DomainReference createDomainReference()
  {
    DomainReferenceImpl domainReference = new DomainReferenceImpl();
    return domainReference;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public MirBasePackage getMirBasePackage()
  {
    return (MirBasePackage)getEPackage();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @deprecated
   * @generated
   */
  @Deprecated
  public static MirBasePackage getPackage()
  {
    return MirBasePackage.eINSTANCE;
  }

} //MirBaseFactoryImpl
