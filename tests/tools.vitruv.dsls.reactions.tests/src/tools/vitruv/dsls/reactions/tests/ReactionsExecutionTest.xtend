package tools.vitruv.dsls.reactions.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.junit.jupiter.api.^extension.ExtendWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.BeforeAll
import java.nio.file.Path
import tools.vitruv.testutils.TestProject
import org.junit.jupiter.api.TestInstance
import edu.kit.ipd.sdq.activextendannotations.Lazy
import static com.google.common.base.Preconditions.checkNotNull
import tools.vitruv.testutils.TestProjectManager
import tools.vitruv.testutils.TestLogging
import tools.vitruv.testutils.views.TestView
import org.eclipse.xtend.lib.annotations.Delegate
import org.junit.jupiter.api.BeforeEach
import tools.vitruv.testutils.TestUserInteraction
import tools.vitruv.change.propagation.ChangePropagationSpecificationRepository
import tools.vitruv.testutils.views.UriMode
import tools.vitruv.testutils.views.ChangePublishingTestView
import static tools.vitruv.testutils.TestModelRepositoryFactory.createTestChangeableModelRepository;
import org.junit.jupiter.api.AfterEach

@ExtendWith(InjectionExtension)
@InjectWith(ReactionsLanguageInjectorProvider)
@TestInstance(PER_CLASS)
@ExtendWith(#[TestLogging, TestProjectManager])
abstract class ReactionsExecutionTest implements TestView {
	@Delegate var TestView testView

	Path compilationDir
	TestReactionsCompiler.Factory factory
	@Lazy
	val TestReactionsCompiler compiler = createCompiler(
		checkNotNull(factory, "The compiler factory was not injected yet!").setParameters [
			reactionsOwner = this
			compilationProjectDir = checkNotNull(compilationDir, "The compilation directory was not acquired yet!")
		]
	)

	protected abstract def TestReactionsCompiler createCompiler(TestReactionsCompiler.Factory factory)

	@BeforeAll
	def void acquireCompilationTargetDir(@TestProject(variant="reactions compilation") Path compilationDir) {
		this.compilationDir = compilationDir
	}

	@BeforeEach
	def void prepareTestView(@TestProject Path testProjectPath) {
		val userInteraction = new TestUserInteraction()
		val changePropagationSpecificationProvider = new ChangePropagationSpecificationRepository(
			changePropagationSpecifications)
		val changeableModelRepository = createTestChangeableModelRepository(changePropagationSpecificationProvider,
			userInteraction)
		testView = new ChangePublishingTestView(testProjectPath, userInteraction, UriMode.FILE_URIS,
			changeableModelRepository)
	}

	@Inject
	def setCompilerFactory(TestReactionsCompiler.Factory factory) {
		this.factory = factory
	}
	
	@AfterEach
	def closeTestView() {
		testView.close()
	}

	def private getChangePropagationSpecifications() {
		compiler.getChangePropagationSpecifications()
	}
}
