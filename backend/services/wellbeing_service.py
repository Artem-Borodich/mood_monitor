from services.wellbeing_constants import ENERGY_WEIGHT, MOOD_WEIGHT, STRESS_WEIGHT


def calculate_wellbeing(mood: int, stress: int, energy: int) -> float:
    index = MOOD_WEIGHT * mood + ENERGY_WEIGHT * energy - STRESS_WEIGHT * stress
    return round(index, 2)
