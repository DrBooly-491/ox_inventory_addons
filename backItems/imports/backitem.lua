local Utils = require 'backItems.imports.utils'

--- @class ItemData
--- @field name string The name of the item.
--- @field prio number The priority of the item.
--- @field hash number | nil The hashed value of the item's name if it's a weapon; nil otherwise.
--- @field model any The model of the item.
--- @field hide boolean
--- @field isWeapon boolean Indicates whether the item is a weapon.
--- @field components table | nil The components of the weapon if it is a weapon; nil otherwise.
--- @field tint any | nil The tint of the weapon if it is a weapon; nil otherwise.
--- @field pos vector3 default attach Position of the item
--- @field rot vector3 default attach Rotation of the item
--- @field customPos {bone: number, rot: vector3 | {x: number,y: number,z: number}, pos: vector3 | {x: number,y: number,z: number}} The custom position of the item.
--- @field ignoreLimits boolean Indicates whether the item should ignore attach limits.
--- @field flashlight boolean

--- @class CBackItem
--- @field playerId number
--- @field object number | nil
--- @field itemData ItemData
--- @field new fun(self, options: any)
--- @field init fun(self, playerId: number, itemData: ItemData)
--- @field create fun(self, model?: number)
--- @field attach fun(self)
--- @field destroy fun(self)
--- @field setVisible fun(self, toggle: boolean)

---@type CBackItem
local BackItem = lib.class('BackItem')

function BackItem:init()
    self:create()
end

function BackItem:create()
    local item = self.itemData
    lib.requestModel(item.model, 1000)
    self.object = CreateObject(item.model, 0.0, 0.0, 0.0, false, false, false)
    SetModelAsNoLongerNeeded(item.model)
    self:attach()
end

function BackItem:attach()
    local ped = GetPlayerPed(self.playerId)
    local item = self.itemData
    local object = self.object
    local customPos = item.customPos

    if item.ignoreLimits and not Utils.isCustomPosValid(customPos) then
        print('^1 ERROR: item with ignoreLimits needs a custom Position^7', item.name)
        self:destroy()
        return
    end

    local pos = item.pos
    local rot = item.rot

    local bone = item.customPos?.bone

    if not object or not DoesEntityExist(object) then return end

    SetEntityCompletelyDisableCollision(self.object, false, false)
    self:setVisible(not item.hide)

    AttachEntityToEntity(
        object,
        ped,
        GetPedBoneIndex(ped, bone or 24818),
        pos.x,
        pos.y,
        pos.z,
        rot.x,
        rot.y,
        rot.z,
        true, false, false, true, 2, true)
end

function BackItem:destroy()
    DeleteEntity(self.object)
    self.object = nil
end

function BackItem:setVisible(toggle)
    SetEntityVisible(self.object, toggle, false)
end

return BackItem
