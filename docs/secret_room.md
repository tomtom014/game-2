# Секретная комната

Готовая сцена: `res://scene/secret_room.tscn`.
На карте она уже стоит в `world/ysort/SecretRoom` — это маленькая комната
вверху справа. Подойди к трещине снизу, повернись вверх клавишей W и нажми ЛКМ.
На втором кадре удара комната с сундуком станет видимой, а преграда исчезнет.

## Как повторить в редакторе

1. Создай сцену с корнем `Node2D`, назови его `SecretRoom`.
2. Внутри создай `Room` (`Node2D`). Все тайлы пола, стен и сундук секретной
   комнаты должны находиться внутри `Room`. Перенеси их с основных слоёв карты,
   чтобы снаружи `Room` не осталось видимых копий.
3. Внутри `Room` добавь `StaticBody2D` с коллизиями по периметру.
   В нижней стене оставь проход. У пола установи `Z Index = -1`.
4. Рядом с `Room` создай `CrackedWall` (`StaticBody2D`). Внутри него:
   `Sprite2D` с текстурой трещины, `EntranceCollision` (`CollisionShape2D`)
   размером с проход и `SealedRoomCollision` (`CollisionShape2D`) на всю скрытую
   комнату. Эти две коллизии не дают пройти до открытия и удаляются вместе с трещиной.
   Текстура: `res://tiles/tiles/wall/wall_crack.png`.
5. Прикрепи `res://scripts/secret_room.gd` к `SecretRoom`. В Inspector перетащи
   `Room` в поле Room, `CrackedWall` в поле Cracked Wall. Поле Break Particles
   необязательное — это только осколки при ударе.
6. Сохрани сцену. Перетащи её в `ysort` в сцене мира. У `SecretRoom`, `Room`
   и слоёв стен/сундука включи Y Sort Enabled.
7. В сцене мира выбери `Player`, открой Signals (вкладка Node / Signals)
   и подключи сигнал `attack_landed` к `SecretRoom`, метод
   `_on_player_attack_landed`. В готовом проекте это уже подключено.
8. Запусти мир. Простая ходьба рядом не открывает комнату: нужен удар
   в сторону трещины с близкого расстояния.

Чтобы добавить ещё такую комнату в этот же проект, достаточно перетащить
готовую сцену на карту, расставить её и подключить к ней сигнал игрока (шаг 7).
Скрипт игрока повторно менять не нужно.

## Код контейнера

```gdscript
extends Node2D

@export var room: Node2D
@export var cracked_wall: StaticBody2D
@export var break_particles: CPUParticles2D

var is_open := false


func _ready() -> void:
	room.hide()


func _on_player_attack_landed(origin: Vector2, direction: Vector2, reach: float) -> void:
	if is_open:
		return

	var to_crack := cracked_wall.global_position - origin
	if to_crack.length() > reach + 8.0:
		return
	if direction.dot(to_crack.normalized()) < 0.6:
		return

	open_secret()


func open_secret() -> void:
	if is_open:
		return

	is_open = true
	room.show()
	cracked_wall.queue_free()
	if break_particles:
		break_particles.emitting = true
```

`origin` — позиция игрока, `direction` — направление удара, `reach` — его дальность.
Первая проверка не даёт открыть секрет издалека. Проверка `dot` исключает удары
в другую сторону. `is_open` не даёт повторно удалить уже удалённую стену.

## Что добавлено в игрока

В `scripts/player.gd` объявлен сигнал:

```gdscript
signal attack_landed(origin: Vector2, direction: Vector2, reach: float)
```

Дальность вынесена в Inspector: `@export var attack_reach: float = 28.0`.
Переменные `_attack_direction` и `_attack_hit_emitted` запоминают направление
и не дают наносить несколько попаданий одной анимацией.
В `_ready()` сигнал спрайта `frame_changed` подключён к обработчику:

```gdscript
func _on_sprite_frame_changed() -> void:
	if is_attacking and not _attack_hit_emitted and sprite.frame >= 1:
		_attack_hit_emitted = true
		attack_landed.emit(global_position, _attack_direction, attack_reach)
```

В `start_attack()` `_attack_hit_emitted` сбрасывается в `false`, а
`_attack_direction` выбирается вместе с анимацией: `UP`, `DOWN`, `LEFT` или `RIGHT`.
Таким образом, сигнал приходит один раз на кадре попадания меча.

## Проверка

В проекте есть проверка `tests/secret_room_test.gd`: скрытие сундука до удара,
закрытый проход, удар издалека/назад, открытие на кадре попадания, проход внутрь
и сохранение коллизий внешних стен.

```text
godot --headless --path . --fixed-fps 60 --script res://tests/secret_room_test.gd
```
