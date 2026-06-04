class_name HealthBarPresenter
extends RefCounted

func ratio(entity: Dictionary) -> float:
	return HealthComponent.health_ratio(entity)
