extends SceneTree
func _init():
    var packed = load('res://assets/models/Island.glb')
    var inst = packed.instantiate()
    print('Root: ', inst.name)
    for child in inst.get_children():
        print(' - ', child.name, ' (', child.get_class(), ')')
        if child is Node3D:
            for sub in child.get_children():
                print('   - ', sub.name, ' (', sub.get_class(), ')')
    quit()
