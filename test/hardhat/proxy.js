import DiamondSol from "../../abi/Diamond.json" assert { type: "json" };
import DiamondCutFacetSol from "../../abi/DiamondCutFacet.json" assert { type: "json" };
import DiamondLoupeFacetSol from "../../abi/DiamondLoupeFacet.json" assert { type: "json" };
import OwnershipFacetSol from "../../abi/OwnershipFacet.json" assert { type: "json" };
import ERC1155FacetSol from "../../abi/ERC1155Facet.json" assert { type: "json" };
import StateProofVerifierFacetSol from "../../abi/StateProofVerifierFacet.json" assert { type: "json" };

import { createERC2535Proxy } from "../../src/erc2535proxy.js";

export const facetABIs = {
  DiamondCutFacet: DiamondCutFacetSol.abi,
  DiamondLoupeFacet: DiamondLoupeFacetSol.abi,
  OwnershipFacet: OwnershipFacetSol.abi,
  StateProofVerifierFacet: StateProofVerifierFacetSol.abi,
  ERC1155FacetSol: ERC1155FacetSol.abi,
};

export function createProxy(diamondAddress, providerOrSigner) {
  return createERC2535Proxy(
    diamondAddress,
    DiamondSol.abi,
    facetABIs,
    providerOrSigner
  );
}
