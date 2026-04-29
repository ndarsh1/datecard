/**
 * Represents a user's Date Style Card — four axes scored 0-100.
 */
export interface DateStyleCard {
  adventurous: number; // 0-100
  planner: number; // 0-100
  talker: number; // 0-100
  foodie: number; // 0-100
}

/**
 * Calculates a compatibility score between two Date Style Cards.
 *
 * For each axis the similarity is (100 - |a - b|), giving 0-100 per axis.
 * The total score ranges from 0 (maximally different) to 400 (identical).
 */
export function dateStyleCompatibilityScore(
  a: DateStyleCard,
  b: DateStyleCard
): number {
  const axes: (keyof DateStyleCard)[] = [
    "adventurous",
    "planner",
    "talker",
    "foodie",
  ];
  return axes.reduce((score, axis) => {
    return score + (100 - Math.abs(a[axis] - b[axis]));
  }, 0);
}
