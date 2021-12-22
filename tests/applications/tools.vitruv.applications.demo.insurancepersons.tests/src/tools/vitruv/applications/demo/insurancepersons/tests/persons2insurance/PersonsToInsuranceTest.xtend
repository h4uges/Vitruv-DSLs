package tools.vitruv.applications.demo.insurancepersons.tests.persons2insurance

import edu.kit.ipd.sdq.metamodels.persons.PersonsFactory
import edu.kit.ipd.sdq.metamodels.persons.PersonRegister
import edu.kit.ipd.sdq.metamodels.insurance.InsuranceDatabase
import org.junit.jupiter.api.TestInfo
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.BeforeEach
import org.apache.log4j.Logger
import tools.vitruv.testutils.VitruvApplicationTest
import tools.vitruv.testutils.domains.DomainUtil
import tools.vitruv.domains.demo.insurance.InsuranceDomainProvider
import tools.vitruv.domains.demo.persons.PersonsDomainProvider
import tools.vitruv.applications.demo.insurancepersons.persons2insurance.PersonsToInsuranceChangePropagationSpecification
import tools.vitruv.applications.demo.insurancepersons.insurance2persons.InsuranceToPersonsChangePropagationSpecification

import static org.hamcrest.CoreMatchers.*
import static org.hamcrest.MatcherAssert.assertThat
import static org.junit.jupiter.api.Assertions.assertEquals
import static tools.vitruv.testutils.matchers.ModelMatchers.*
import edu.kit.ipd.sdq.metamodels.insurance.InsuranceFactory
import edu.kit.ipd.sdq.metamodels.insurance.Gender
import java.nio.file.Path

class PersonsToInsuranceTest extends VitruvApplicationTest {
	static val logger = Logger.getLogger(PersonsToInsuranceTest)
	TestInfo testInfo = null
	
	static val MALE_NAME = "Max Mustermann"
	static val MALE_NAME_2 = "Bernd Mustermann"
	static val FEMALE_NAME = "Erika Mustermann"
	static val FEMALE_NAME_2 = "Berta Mustermann"
	static val FEMALE_NAME_3 = "Berta Musterfrau"
	// Model Paths
	final static Path PERSONS_MODEL = DomainUtil.getModelFileName('model/persons', new PersonsDomainProvider)
	final static Path INSURANCE_MODEL = DomainUtil.getModelFileName('model/insurance', new InsuranceDomainProvider)

	/**Set the correct set of reactions and routines for this test suite
	 */
	override protected getChangePropagationSpecifications() {
		return #[new InsuranceToPersonsChangePropagationSpecification(),
			new PersonsToInsuranceChangePropagationSpecification()]
	}

	/**Before each test a new {@link PersonRegister} is created as starting point.
	 * This is checked by several assertions to ensure correct preconditions for the tests. 
	 */
	@BeforeEach
	def void insertRegister(TestInfo testInfo) {
		this.testInfo = testInfo
		resourceAt(PERSONS_MODEL).propagate[contents += PersonsFactory.eINSTANCE.createPersonRegister]
		assertThat(resourceAt(INSURANCE_MODEL), exists);
		assertEquals(1, resourceAt(INSURANCE_MODEL).contents.size);
		assertEquals(1, resourceAt(INSURANCE_MODEL).allContents.size);
		assertThat(resourceAt(INSURANCE_MODEL).contents.get(0), instanceOf(InsuranceDatabase));
		assertEquals(0, resourceAt(INSURANCE_MODEL).contents.get(0).eAllContents().size);
	}
	
	/**Check if the actual {@link PersonRegister} looks like the expected one.
	 */
	def void assertCorrectPersonRegister(PersonRegister expectedPersonRegister) {
		val personModel = resourceAt(PERSONS_MODEL)
		assertThat(personModel, exists)
		assertEquals(1, personModel.contents.size)
		val personRegister = personModel.contents.get(0)
		assertThat(personRegister, instanceOf(PersonRegister))
		val PersonRegister castedPersonRegister = personRegister as PersonRegister
		assertThat(castedPersonRegister, equalsDeeply(expectedPersonRegister))
	}
	
	/**Check if the actual {@link InsuranceDatabase} looks like the expected one.
	 */
	def void assertCorrectInsuranceDatabase(InsuranceDatabase expectedInsuranceDatabase) {
		val insuranceModel = resourceAt(INSURANCE_MODEL)
		assertThat(insuranceModel, exists)
		assertEquals(1, insuranceModel.contents.size)
		val insuranceDatabase = insuranceModel.contents.get(0)
		assertThat(insuranceDatabase, instanceOf(InsuranceDatabase))
		val InsuranceDatabase castedInsuranceDatabase = insuranceDatabase as InsuranceDatabase
		assertThat(castedInsuranceDatabase, equalsDeeply(expectedInsuranceDatabase))
	}
	
	def void createPersonsAndPropagate() {
		PersonRegister.from(PERSONS_MODEL).propagate [
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME]
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME]
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME_2]
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME_2]
		]
	}
	
	def createPersonsForTesting() {
		val PersonRegister expectedPersonRegister = PersonsFactory.eINSTANCE.createPersonRegister => [
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME]
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME]
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME_2]
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME_2]
		]
		return expectedPersonRegister
	}
	
	def createClientsForTesting() {
		val InsuranceDatabase expectedInsuranceDatabase = InsuranceFactory.eINSTANCE.createInsuranceDatabase => [
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = MALE_NAME
				// socialSecurityNumber = 000
				gender = Gender.MALE
			]
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = FEMALE_NAME
				// socialSecurityNumber = 000
				gender = Gender.FEMALE
			]
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = MALE_NAME_2
				// socialSecurityNumber = 000
				gender = Gender.MALE
			]
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = FEMALE_NAME_2
				// socialSecurityNumber = 000
				gender = Gender.FEMALE
			]
		]
		return expectedInsuranceDatabase
	}
	
	def void testExample() {
		val String surroundingMethodName = this.testInfo.getDisplayName()
		logger.trace(surroundingMethodName + " - begin")
		logger.trace(surroundingMethodName + " - preparation done")
		logger.trace(surroundingMethodName + " - propagation done")
		logger.trace(surroundingMethodName + " - finished without errors")
	}

	@Test
	def testCreatePersonsModel() {
		val String surroundingMethodName = this.testInfo.getDisplayName()
		logger.trace(surroundingMethodName + " - begin")
		assertThat(resourceAt(INSURANCE_MODEL), exists)
		assertThat(resourceAt(PERSONS_MODEL), exists)
		//TODO
		logger.trace(surroundingMethodName + " - finished without errors")
	}
	
	@Test
	def void testDeletePersonsRegister() {
		val String surroundingMethodName = this.testInfo.getDisplayName()
		logger.trace(surroundingMethodName + " - begin")
		this.createPersonsAndPropagate();
		logger.trace(surroundingMethodName + " - preparation done")
		resourceAt(PERSONS_MODEL).propagate[contents.clear()]
		logger.trace(surroundingMethodName + " - propagation done")
		assertEquals(0, resourceAt(INSURANCE_MODEL).contents.size())
		assertEquals(0, resourceAt(PERSONS_MODEL).contents.size())
		assertThat(resourceAt(INSURANCE_MODEL), not(exists))
		assertThat(resourceAt(PERSONS_MODEL), not(exists))
		logger.trace(surroundingMethodName + " - finished without errors")
	}

	@Test
	def void testCreatedPerson_male_emptyDatabase() {
		val String surroundingMethodName = this.testInfo.getDisplayName()
		logger.trace(surroundingMethodName + " - begin")
		
		logger.trace(surroundingMethodName + " - preparation done")
		
		PersonRegister.from(PERSONS_MODEL).propagate [
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME]
		]
		logger.trace(surroundingMethodName + " - propagation done")
		
		val InsuranceDatabase expectedInsuranceDatabase = InsuranceFactory.eINSTANCE.createInsuranceDatabase => [
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = MALE_NAME
				// socialSecurityNumber = 000
				gender = Gender.MALE
			]
		]
		val PersonRegister expectedPersonRegister = PersonsFactory.eINSTANCE.createPersonRegister => [
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME]
		]
		assertCorrectInsuranceDatabase(expectedInsuranceDatabase)
		assertCorrectPersonRegister(expectedPersonRegister)
		logger.trace(surroundingMethodName + " - finished without errors")
	}
	
	@Test
	def void testCreatedPerson_female_emptyDatabase() {
		val String surroundingMethodName = this.testInfo.getDisplayName()
		logger.trace(surroundingMethodName + " - begin")
		
		logger.trace(surroundingMethodName + " - preparation done")
		
		PersonRegister.from(PERSONS_MODEL).propagate [
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME]
		]
		logger.trace(surroundingMethodName + " - propagation done")
		
		val InsuranceDatabase expectedInsuranceDatabase = InsuranceFactory.eINSTANCE.createInsuranceDatabase => [
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = FEMALE_NAME
				// socialSecurityNumber = 000
				gender = Gender.FEMALE
			]
		]
		val PersonRegister expectedPersonRegister = PersonsFactory.eINSTANCE.createPersonRegister => [
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME]
		]
		assertCorrectInsuranceDatabase(expectedInsuranceDatabase)
		assertCorrectPersonRegister(expectedPersonRegister)
		logger.trace(surroundingMethodName + " - finished without errors")
	}
	
	@Test
	def void testCreatedPerson_multiple() {
		val String surroundingMethodName = this.testInfo.getDisplayName()
		logger.trace(surroundingMethodName + " - begin")
		
		logger.trace(surroundingMethodName + " - preparation done")
		
		PersonRegister.from(PERSONS_MODEL).propagate [
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME]
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME]
		]
		PersonRegister.from(PERSONS_MODEL).propagate [
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME_2]
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME_2]
		]
		logger.trace(surroundingMethodName + " - propagation done")
		
		val InsuranceDatabase expectedInsuranceDatabase = createClientsForTesting()
		val PersonRegister expectedPersonRegister = createPersonsForTesting()
		
		assertCorrectInsuranceDatabase(expectedInsuranceDatabase)
		assertCorrectPersonRegister(expectedPersonRegister)
		logger.trace(surroundingMethodName + " - finished without errors")
	}
	
	@Test
	def void testChangedFullName() {
		val String surroundingMethodName = this.testInfo.getDisplayName()
		logger.trace(surroundingMethodName + " - begin")
		
		createPersonsAndPropagate()
		logger.trace(surroundingMethodName + " - preparation done")
		
		PersonRegister.from(PERSONS_MODEL).propagate [
			val searchedPerson = persons.findFirst[x|x.fullName.equals(FEMALE_NAME_2)]
			searchedPerson.fullName = FEMALE_NAME_3
		]
		logger.trace(surroundingMethodName + " - propagation done")
		
		val PersonRegister expectedPersonRegister = PersonsFactory.eINSTANCE.createPersonRegister => [
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME]
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME]
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME_2]
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME_3]
		]
		val InsuranceDatabase expectedInsuranceDatabase = InsuranceFactory.eINSTANCE.createInsuranceDatabase => [
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = MALE_NAME
				// socialSecurityNumber = 000
				gender = Gender.MALE
			]
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = FEMALE_NAME
				// socialSecurityNumber = 000
				gender = Gender.FEMALE
			]
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = MALE_NAME_2
				// socialSecurityNumber = 000
				gender = Gender.MALE
			]
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = FEMALE_NAME_3
				// socialSecurityNumber = 000
				gender = Gender.FEMALE
			]
		]
		assertCorrectInsuranceDatabase(expectedInsuranceDatabase)
		assertCorrectPersonRegister(expectedPersonRegister)
		logger.trace(surroundingMethodName + " - finished without errors")
	}
	
	@Test
	def void testDeletedPerson_first_notOnely() {
		val String surroundingMethodName = this.testInfo.getDisplayName()
		logger.trace(surroundingMethodName + " - begin")
		
		createPersonsAndPropagate()
		logger.trace(surroundingMethodName + " - preparation done")
		
		PersonRegister.from(PERSONS_MODEL).propagate [
			val searchedPerson = persons.findFirst[x|x.fullName.equals(MALE_NAME)]
			persons.remove(searchedPerson)
		]
		logger.trace(surroundingMethodName + " - propagation done")
		
		val PersonRegister expectedPersonRegister = PersonsFactory.eINSTANCE.createPersonRegister => [
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME]
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME_2]
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME_2]
		]
		val InsuranceDatabase expectedInsuranceDatabase = InsuranceFactory.eINSTANCE.createInsuranceDatabase => [
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = FEMALE_NAME
				// socialSecurityNumber = 000
				gender = Gender.FEMALE
			]
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = MALE_NAME_2
				// socialSecurityNumber = 000
				gender = Gender.MALE
			]
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = FEMALE_NAME_2
				// socialSecurityNumber = 000
				gender = Gender.FEMALE
			]
		]
		assertCorrectInsuranceDatabase(expectedInsuranceDatabase)
		assertCorrectPersonRegister(expectedPersonRegister)
		logger.trace(surroundingMethodName + " - finished without errors")
	}

	@Test
	def void testDeletedPerson_middle_notOnely() {
		val String surroundingMethodName = this.testInfo.getDisplayName()
		logger.trace(surroundingMethodName + " - begin")
		
		createPersonsAndPropagate()
		logger.trace(surroundingMethodName + " - preparation done")
		
		PersonRegister.from(PERSONS_MODEL).propagate [
			val searchedPerson = persons.findFirst[x|x.fullName.equals(FEMALE_NAME)]
			persons.remove(searchedPerson)
		]
		logger.trace(surroundingMethodName + " - propagation done")
		
		val PersonRegister expectedPersonRegister = PersonsFactory.eINSTANCE.createPersonRegister => [
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME]
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME_2]
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME_2]
		]
		val InsuranceDatabase expectedInsuranceDatabase = InsuranceFactory.eINSTANCE.createInsuranceDatabase => [
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = MALE_NAME
				// socialSecurityNumber = 000
				gender = Gender.MALE
			]
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = MALE_NAME_2
				// socialSecurityNumber = 000
				gender = Gender.MALE
			]
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = FEMALE_NAME_2
				// socialSecurityNumber = 000
				gender = Gender.FEMALE
			]
		]
		assertCorrectInsuranceDatabase(expectedInsuranceDatabase)
		assertCorrectPersonRegister(expectedPersonRegister)
		logger.trace(surroundingMethodName + " - finished without errors")
	}
	
	@Test
	def void testDeletedPerson_last_notOnely() {
		val String surroundingMethodName = this.testInfo.getDisplayName()
		logger.trace(surroundingMethodName + " - begin")
		
		createPersonsAndPropagate()
		logger.trace(surroundingMethodName + " - preparation done")
		
		PersonRegister.from(PERSONS_MODEL).propagate [
			val searchedPerson = persons.findFirst[x|x.fullName.equals(FEMALE_NAME_2)]
			persons.remove(searchedPerson)
		]
		logger.trace(surroundingMethodName + " - propagation done")
		
		val PersonRegister expectedPersonRegister = PersonsFactory.eINSTANCE.createPersonRegister => [
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME]
			persons += PersonsFactory.eINSTANCE.createFemale => [fullName = FEMALE_NAME]
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME_2]
		]
		val InsuranceDatabase expectedInsuranceDatabase = InsuranceFactory.eINSTANCE.createInsuranceDatabase => [
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = MALE_NAME
				// socialSecurityNumber = 000
				gender = Gender.MALE
			]
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = FEMALE_NAME
				// socialSecurityNumber = 000
				gender = Gender.FEMALE
			]
			insuranceclient += InsuranceFactory.eINSTANCE.createInsuranceClient => [
				name = MALE_NAME_2
				// socialSecurityNumber = 000
				gender = Gender.MALE
			]
		]
		assertCorrectInsuranceDatabase(expectedInsuranceDatabase)
		assertCorrectPersonRegister(expectedPersonRegister)
		logger.trace(surroundingMethodName + " - finished without errors")
	}
	
	@Test
	def void testDeletedPerson_onely() {
		val String surroundingMethodName = this.testInfo.getDisplayName()
		logger.trace(surroundingMethodName + " - begin")
		
		PersonRegister.from(PERSONS_MODEL).propagate [
			persons += PersonsFactory.eINSTANCE.createMale => [fullName = MALE_NAME]
		]
		logger.trace(surroundingMethodName + " - preparation done")
		
		PersonRegister.from(PERSONS_MODEL).propagate [
			val searchedPerson = persons.findFirst[x|x.fullName.equals(MALE_NAME)]
			persons.remove(searchedPerson)
		]
		logger.trace(surroundingMethodName + " - propagation done")
		
		val PersonRegister expectedPersonRegister = PersonsFactory.eINSTANCE.createPersonRegister => [
		]
		val InsuranceDatabase expectedInsuranceDatabase = InsuranceFactory.eINSTANCE.createInsuranceDatabase => [
		]
		assertCorrectInsuranceDatabase(expectedInsuranceDatabase)
		assertCorrectPersonRegister(expectedPersonRegister)
		logger.trace(surroundingMethodName + " - finished without errors")
	}
}

	