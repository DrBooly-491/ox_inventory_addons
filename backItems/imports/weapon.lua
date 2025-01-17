local CBackItem = require 'backItems.imports.backitem'
local Utils = require 'backItems.imports.utils'
local ox_items = exports.ox_inventory:Items()

--- @class CBackWeapon : CBackItem
--- @field new fun(self, options: any)
--- @field init fun(self, playerId: number, itemData: ItemData)
--- @field create fun(self, model?: number)
--- @field getComponents fun(self, model?: number)
--- @field attachComponents fun(self)
--- @field checkVarMod fun(self)
--- @field hasFlashLight fun(self): boolean
--- @field varMod number | nil
--- @field hadClip boolean
--- @field weaponComponents table<string | number>

---@type CBackWeapon
local BackWeapon = lib.class('BackWeapon', CBackItem)

function BackWeapon:init()
    self:create()
end

function BackWeapon:checkVarMod()
    local components = self.itemData.components

    if not components then return end

    for i = 1, #components do
        local component = ox_items[components[i]]

        if component.type == 'skin' or component.type == 'upgrade' then
            local weaponComp = component.client.component
            for j = 1, #weaponComp do
                local weaponComponent = weaponComp[j]
                if DoesWeaponTakeWeaponComponent(self.itemData.hash, weaponComponent) then
                    self.varMod =  GetWeaponComponentTypeModel(weaponComponent)
                end
            end
        end
    end
end

function BackWeapon:getComponents()
    local itemData = self.itemData
    local name, hash, components = itemData.name, itemData.hash, itemData.components
    local weaponComponents = {}
    local amount = 0
    self.hadClip = false

    self:checkVarMod()

    for i = 1, #components do
        local weaponComp = ox_items[components[i]]
        for j = 1, #weaponComp.client.component do
            local weaponComponent = weaponComp.client.component[j]
            if DoesWeaponTakeWeaponComponent(hash, weaponComponent) and self.varMod ~= weaponComponent then
                amount += 1
                weaponComponents[amount] = weaponComponent

                if weaponComp.type == 'magazine' then
                    self.hadClip = true
                end

                break
            end
        end
    end

    if not self.hadClip then
        amount += 1
        weaponComponents[amount] = joaat(('COMPONENT_%s_CLIP_01'):format(name:sub(8)))
    end

    self.weaponComponents = weaponComponents
end

function BackWeapon:create()
    self:getComponents()
    local item = self.itemData

    lib.requestWeaponAsset(item.hash, 1000, 31, 0)

    if self.varMod and not HasModelLoaded(self.varMod) then
        lib.requestModel(self.varMod, 500)
    end

    local showDefault = true

    if self.varMod and self.hadClip then
        showDefault = false
    end

    self.object = CreateWeaponObject(item.hash, 0, 0.0, 0.0, 0.0, showDefault, 1.0, self.varMod or 0, false, false)

    for i = 1, #self.weaponComponents do
        GiveWeaponComponentToWeaponObject(self.object, self.weaponComponents[i])
    end

    if item.tint then
        SetWeaponObjectTintIndex(self.object, item.tint)
    end

    if item.flashlight then
        SetCreateWeaponObjectLightSource(self.object, true)
        Wait(0)
    end

    RemoveWeaponAsset(item.hash)

    self:attach()
end

return BackWeapon
