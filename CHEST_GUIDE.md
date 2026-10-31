# Открываемый сундук и +1 ключ

Инструкция под текущий проект после pull. Существующие движение, атаку и GUI переписывать не нужно.

Сейчас GUI уже создан: `Player → GUI → HBoxContainer → KeyNumber`. Действие `interact` уже существует и назначено на **правую кнопку мыши**. 

## 1. Добавь количество ключей игроку

Открой `scripts/player.gd`.

Под строкой `var is_dead := false` добавь:

```gdscript
var keys := 0
```

В конец существующей функции `_ready()` добавь строку с одним отступом Tab:

```gdscript
	$GUI/HBoxContainer/KeyNumber.text = "Key x %02d" % keys
```

В самый конец файла добавь отдельную функцию, без отступа перед `func`:

```gdscript
func add_key() -> void:
	keys += 1
	$GUI/HBoxContainer/KeyNumber.text = "Key x %02d" % keys
```

Получится `Key x 00`, после первого сундука — `Key x 01`, после второго — `Key x 02`.

## 2. Создай сцену сундука

Создай новую сцену с корнем **Area2D**, назови корень `Chest`.

Добавь два дочерних узла:

```text
Chest (Area2D)
├── Sprite2D
└── CollisionShape2D
```

У `CollisionShape2D` в поле Shape выбери **New RectangleShape2D**. Сделай прямоугольник немного больше картинки сундука, например 32 × 32 для сундука размером 16 × 16. Это область взаимодействия: игрок должен войти в неё, чтобы открыть сундук.

У корня `Chest` оставь **Monitoring** включённым. В **Collision Mask** включи слой игрока — при стандартных настройках это слой 1. Сам Area2D движению игрока не мешает.

Сохрани сцену как `scene/chest.tscn`.

## 3. Прикрепи скрипт сундука

Выдели корень `Chest` и прикрепи новый скрипт `scripts/chest.gd`. Вставь в этот новый файл:

```gdscript
extends Area2D

@export var closed_texture: Texture2D
@export var opened_texture: Texture2D

var is_open := false


func _ready() -> void:
	$Sprite2D.texture = closed_texture


func _unhandled_input(event: InputEvent) -> void:
	if is_open or not is_visible_in_tree():
		return
	if not event.is_action_pressed("interact") or event.is_echo():
		return

	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			if body.is_dead:
				continue
			is_open = true
			$Sprite2D.texture = opened_texture
			body.add_key()
			get_viewport().set_input_as_handled()
			break
```

`is_open` не позволяет повторно получить ключ из того же сундука. Каждый экземпляр сундука имеет своё состояние.

## 4. Назначь картинки

Выдели корень `Chest`. В инспекторе появятся **Closed Texture** и **Opened Texture**.

Для **Closed Texture**:

1. Нажми стрелку у поля → **New AtlasTexture**.
2. Нажми на созданную AtlasTexture.
3. В **Atlas** перетащи PNG тайлсета с сундуками, а не ресурс `.tres`.
4. В **Region → Edit Region** выдели закрытый сундук.

Для **Opened Texture** создай **отдельную New AtlasTexture** и таким же способом выдели открытый сундук. Размер выделения должен совпадать с закрытой картинкой, чтобы сундук не смещался.

Скрипт назначает закрытую картинку при запуске. Чтобы видеть её и в редакторе, назначь ту же закрытую AtlasTexture в поле **Texture** узла `Sprite2D`.

Сохрани сцену.

## 5. Поставь сундук на уровень

Открой игровую сцену `world.tscn`. Перетащи `scene/chest.tscn` из FileSystem на уровень и поставь на нужное место. Можно добавить его внутрь `ysort`, где находится игрок.

Если на этом месте уже нарисован сундук тайлами, сотри только его тайл: теперь его изображает новая сцена.

Если заменяешь сундук именно в `scene/secret_room.tscn`, старый `Room/Chest` является TileMapLayer. Удали его старый тайл и добавь новый экземпляр `chest.tscn` внутрь `Room`. Тогда новый сундук будет скрываться вместе с комнатой. Скрипт `secret_room.gd` менять не требуется.

## 6. Проверь

1. Сохрани изменённые сцены и скрипты.
2. Запусти игру: счётчик должен показывать `Key x 00`.
3. Подойди к сундуку и нажми ПКМ: картинка должна смениться на открытую, счётчик — на `Key x 01`.
4. Нажми ещё раз: число не должно увеличиться.
5. Открой второй экземпляр сундука: получишь `Key x 02`.

Если сундук не реагирует, проверь группу `player` у корня игрока, пересечение игрока с областью `CollisionShape2D` сундука и Collision Mask этой области. Если возникает ошибка пути к счётчику, имя узла должно быть именно `KeyNumber`, а полный путь — `GUI/HBoxContainer/KeyNumber`.

Этот вариант хранит ключи и состояние сундуков на время текущего запуска. Сохранение между запусками здесь не добавляется.
