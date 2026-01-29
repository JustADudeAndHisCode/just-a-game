extends Node

var return_scene_path := ""

func enter_minigame(scene_path: String) -> void:
    return_scene_path = get_tree().current_scene.scene_file_path
    get_tree().change_scene_to_file(scene_path)

func exit_minigame() -> void:
    if return_scene_path == "":
        return
    get_tree().change_scene_to_file(return_scene_path)
