package tools.vitruv.dsls.mappings.tests.addressesXrecipients.mappings.halves

import tools.vitruv.extensions.dslsruntime.mappings.MappingInstanceHalf
import edu.kit.ipd.sdq.mdsd.addresses.Address
import org.eclipse.xtend.lib.annotations.Data

@Data class LeftAddressXRecipientLocationCityInstanceHalf extends MappingInstanceHalf {
	LeftAdRootXReRootInstanceHalf rootXroot
	Address a
	
	override getElements() {
		return #[a]
	}
	
	override checkConditions() {
		return super.checkConditions() && 
		rootXroot.ARoot.addresses.contains(a) && 
		a.number > 0 &&
		a.zipCode != null
	}

	override enforceConditions() {
		// enforce a in rootXroot:aRoot.addresses
		rootXroot.ARoot.addresses.add(a)
		// enforce a.number > 0
      	if (a.number <= 0) {
			a.number = 0
		}
      	// enforce a.zipCode != null
      	if (a.zipCode == null) {
			a.zipCode == ""
		}
	}
}