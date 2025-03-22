
import { type RulesMap } from "../../types.js";
import { isDestinationRandomTestnet } from "../filler.js";

/**
 * Custom rules for the solver.
 * These rules are used to determine if the solver should process a given intent.
 */

// Export the rules map with our custom rules
export const rules: RulesMap<Promise<{ success: boolean; error?: string; data?: string }>> = {
  isDestinationRandomTestnet
};

// Export the create function that returns the rules
export const create = () => rules;
