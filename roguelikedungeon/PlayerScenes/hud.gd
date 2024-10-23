#Most of this script is called outside this, in playerController.gd

extends CanvasLayer

var quitMenuShown : bool = false
var invMenuShown : bool = false
var skillMenuShown : bool = false

@onready var skill1 = $SkillMenu/Hero1
@onready var skill2 = $SkillMenu/Hero2
@onready var skill3 = $SkillMenu/Hero3
@onready var skill4 = $SkillMenu/Hero4

var time0 = 0
var time1 = 0
var time2 = 0
var time3 = 0
var pos0
var pos1
var pos2
var pos3

func _ready():
	hideAllHUD()
	pos0 = $Abilities/Control/Ability1Panel/Label.position
	pos1 = $Abilities/Control/Ability2Panel/Label.position
	pos2 = $Abilities/Control/Ability3Panel/Label.position
	pos3 = $Abilities/Control/Ability4Panel/Label.position

func _process(delta):
	if Globals.isPaused:
		return
	
	if time0 > 0:
		if ceil(time0) <= 9:
			$Abilities/Control/Ability1Panel/Label.position.x = pos0.x + 9
		else:
			$Abilities/Control/Ability1Panel/Label.position.x = pos0.x
		time0 -= delta
		$Abilities/Control/Ability1Panel.visible = true
		$Abilities/Control/Ability1Panel/Label.set_text(str(ceil(time0)))
	else:
		$Abilities/Control/Ability1Panel.visible = false
	
	if time1 > 0:
		if ceil(time1) <= 9:
			$Abilities/Control/Ability2Panel/Label.position.x = pos1.x + 9
		else:
			$Abilities/Control/Ability2Panel/Label.position.x = pos1.x
		time1 -= delta
		$Abilities/Control/Ability2Panel.visible = true
		$Abilities/Control/Ability2Panel/Label.set_text(str(ceil(time1)))
	else:
		$Abilities/Control/Ability2Panel.visible = false
	
	if time2 > 0:
		if ceil(time2) <= 9:
			$Abilities/Control/Ability3Panel/Label.position.x = pos2.x + 9
		else:
			$Abilities/Control/Ability3Panel/Label.position.x = pos2.x
		time2 -= delta
		$Abilities/Control/Ability3Panel.visible = true
		$Abilities/Control/Ability3Panel/Label.set_text(str(ceil(time2)))
	else:
		$Abilities/Control/Ability3Panel.visible = false
		
	if time3 > 0:
		if ceil(time3) <= 9:
			$Abilities/Control/Ability4Panel/Label.position.x = pos3.x + 9
		else:
			$Abilities/Control/Ability4Panel/Label.position.x = pos3.x
		time3 -= delta
		$Abilities/Control/Ability4Panel.visible = true
		$Abilities/Control/Ability4Panel/Label.set_text(str(ceil(time3)))
	else:
		$Abilities/Control/Ability4Panel.visible = false

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

func writeInvMenu():
	var knightText  = $InventoryMenu/Control/Stats
	#knightText.set_text("AD : ")
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
		$Abilities/Control/Ability1Name.set_text(heroArrayReference[0].abilitySelected)
		$Abilities/Control/Ability2Name.set_text(heroArrayReference[1].abilitySelected)
		$Abilities/Control/Ability3Name.set_text(heroArrayReference[2].abilitySelected)
		$Abilities/Control/Ability4Name.set_text(heroArrayReference[3].abilitySelected)

#abilitiy is 0-3, for respective index of ability
#Time is countdown in seconds.
func startHudCooldown(ability, time):
	if ability == 0:
		time0 = time
	if ability == 1:
		time1 = time
	if ability == 2:
		time2 = time
	if ability == 3:
		time3 = time
