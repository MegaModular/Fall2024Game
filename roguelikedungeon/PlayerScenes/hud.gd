#Most of this script is called outside this, in playerController.gd

extends CanvasLayer

var quitMenuShown : bool = false
var invMenuShown : bool = false
var skillMenuShown : bool = false

@onready var skill1 = $SkillMenu/Hero1
@onready var skill2 = $SkillMenu/Hero2
@onready var skill3 = $SkillMenu/Hero3
@onready var skill4 = $SkillMenu/Hero4

func _ready():
	hideAllHUD()

#Calllable Functions
func isHUDShown() -> bool:
	if quitMenuShown || invMenuShown || skillMenuShown:
		return true
	return false

func showINV():
	$InventoryMenu.visible = true
	invMenuShown = true

func hideINV():
	$InventoryMenu.visible = false
	invMenuShown = false

func showHUD():
	hideAllHUD()
	$QuitMenu.visible = true
	quitMenuShown = true

func hideHUD():
	hideAllHUD()
	$QuitMenu.visible = false
	quitMenuShown = false

func hideAllHUD():
	$SkillMenu.visible = false
	$InventoryMenu.visible = false
	$QuitMenu.visible = false
	quitMenuShown = false
	invMenuShown = false
	skillMenuShown = false

func showSKILL():
	$SkillMenu.visible = true
	skillMenuShown = true
	writeSkillMenu()

func hideSKILL():
	skillMenuShown = false
	$SkillMenu.visible = false

	

#Dynamically updates the skill menu. AAAAAAAAAAAAAAAAA
func writeSkillMenu():
	#Show the correct amount of options.
	skill1.visible = false
	skill2.visible = false
	skill3.visible = false
	skill4.visible = false
	#Makes the menu visible.
	var heroCount = $"../../Heroes".get_child_count()
	var heroArrayReference = $"../../Heroes".get_children()
	if heroCount > 0:
		skill1.visible = true
		var skillButtons  = [$SkillMenu/Hero1/CheckButton, $SkillMenu/Hero1/CheckButton2, $SkillMenu/Hero1/CheckButton3]
		var x = heroArrayReference[0].heroClass
		$SkillMenu/Hero1/Label.set_text(x.capitalize())
		skillButtons[0].set_text(heroArrayReference[0].abilities[0])
		skillButtons[1].set_text(heroArrayReference[0].abilities[1])
		skillButtons[2].set_text(heroArrayReference[0].abilities[2])
	if heroCount > 1:
		skill2.visible = true
		var skillButtons  = [$SkillMenu/Hero2/CheckButton, $SkillMenu/Hero2/CheckButton2, $SkillMenu/Hero2/CheckButton3]
		var x = heroArrayReference[1].heroClass
		$SkillMenu/Hero2/Label.set_text(x.capitalize())
		skillButtons[0].set_text(heroArrayReference[1].abilities[0])
		skillButtons[1].set_text(heroArrayReference[1].abilities[1])
		skillButtons[2].set_text(heroArrayReference[1].abilities[2])
	if heroCount > 2:
		skill3.visible = true
		var skillButtons  = [$SkillMenu/Hero3/CheckButton, $SkillMenu/Hero3/CheckButton2, $SkillMenu/Hero3/CheckButton3]
		var x = heroArrayReference[2].heroClass
		$SkillMenu/Hero3/Label.set_text(x.capitalize())
		skillButtons[0].set_text(heroArrayReference[2].abilities[0])
		skillButtons[1].set_text(heroArrayReference[2].abilities[1])
		skillButtons[2].set_text(heroArrayReference[2].abilities[2])
	if heroCount > 3:
		skill4.visible = true
		var skillButtons  = [$SkillMenu/Hero4/CheckButton, $SkillMenu/Hero4/CheckButton2, $SkillMenu/Hero4/CheckButton3]
		var x = heroArrayReference[3].heroClass
		$SkillMenu/Hero4/Label.set_text(x.capitalize())
		skillButtons[0].set_text(heroArrayReference[3].abilities[0])
		skillButtons[1].set_text(heroArrayReference[3].abilities[1])
		skillButtons[2].set_text(heroArrayReference[3].abilities[2])
	
	
	

#Signal Functions
func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_resume_pressed() -> void:
	Globals.isPaused = false
	hideHUD()

#Toggled on: true, num = which button toggled, heroNum = which hero editing.
#Called whenever a button is pressed to select a skill.
func _Hero1ButtonHandling(toggled_on: bool, num: int, heroNum : int) -> void:
	var heroArrayReference = $"../../Heroes".get_children()
	if toggled_on:
		#First "hero"
		var skillButtons
		if heroNum == 0:
			skillButtons  = [$SkillMenu/Hero1/CheckButton, $SkillMenu/Hero1/CheckButton2, $SkillMenu/Hero1/CheckButton3]
		if heroNum == 1:
			skillButtons  = [$SkillMenu/Hero2/CheckButton, $SkillMenu/Hero2/CheckButton2, $SkillMenu/Hero2/CheckButton3]
		if heroNum == 2:
			skillButtons  = [$SkillMenu/Hero3/CheckButton, $SkillMenu/Hero3/CheckButton2, $SkillMenu/Hero3/CheckButton3]
		if heroNum == 3:
			skillButtons  = [$SkillMenu/Hero4/CheckButton, $SkillMenu/Hero4/CheckButton2, $SkillMenu/Hero4/CheckButton3]
		
		#Turns off other abilities while one is selected.
		for i in range(3):
			if i != num:
				skillButtons[i].button_pressed = false
		#Important line, assigns selected variable.
		heroArrayReference[heroNum].abilitySelected = heroArrayReference[heroNum].abilities[num]
		#Debug
		#print(heroArrayReference[heroNum].abilitySelected)
