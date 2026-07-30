local KeybindsList = {
    ["PreviousTarget"] = {
        desc = "Previous Target",
        keybinds = { "A" },
        order = 1
    },
    ["NextTarget"] = {
        desc = "Next Target",
        keybinds = { "D" },
        order = 2
    },
    ["BasicAttack"] = {
        desc = "Basic Attack",
        keybinds = { "Q" },
        order = 3
    },
    ["Skill"] = {
        desc = "Skill",
        keybinds = { "E" },
        order = 4
    },
    ["Ultimate"] = {
        desc = "Ultimate",
        keybinds = {"1", "2", "3"},
        order = 5
    },
    ["SkipTurn"] = {
        desc = "Skip Turn",
        keybinds = { "Z" },
        order = 6
    }
}

local function createKeybindButtons(keybind)
    local keybindOuterFrame = Instance.new("Frame")
    keybindOuterFrame.Name = "KeybindOuterFrame"
    keybindOuterFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    keybindOuterFrame.Size = UDim2.fromScale(1, 1)

    local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
    uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
    uIAspectRatioConstraint.Parent = keybindOuterFrame

    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Name = "Keybind"
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.FontFace = Font.new(
        "rbxasset://fonts/families/Balthazar.json",
        Enum.FontWeight.Bold,
        Enum.FontStyle.Normal
    )
    keybindLabel.Position = UDim2.fromScale(0.15, 0.15)
    keybindLabel.Size = UDim2.fromScale(0.7, 0.7)
    keybindLabel.Text = keybind
    keybindLabel.TextColor3 = Color3.new()
    keybindLabel.TextScaled = true
    keybindLabel.Parent = keybindOuterFrame

    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.Parent = keybindOuterFrame

    return keybindOuterFrame
end

local function createKeybindEntry(desc, order, keybindsList)
    local keybindsItem = Instance.new("Frame")
    keybindsItem.Name = "KeybindsItem"
    keybindsItem.BackgroundTransparency = 1
    keybindsItem.Size = UDim2.fromScale(1, 0.12)
    keybindsItem.LayoutOrder = order

    local keybinds = Instance.new("Frame")
    keybinds.Name = "Keybinds"
    keybinds.BackgroundTransparency = 1
    keybinds.LayoutOrder = 1
    keybinds.Size = UDim2.fromScale(0.4, 1)

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Name = "uiListLayout"
    uiListLayout.FillDirection = Enum.FillDirection.Horizontal
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Padding = UDim.new(0, 6)
    uiListLayout.Parent = keybinds

    for _, keybind in pairs(keybindsList) do
        local keybindButton = createKeybindButtons(keybind)
        keybindButton.Parent = keybinds
    end

    local itemUIListLayout = Instance.new("UIListLayout")
    itemUIListLayout.Name = "UIListLayout"
    itemUIListLayout.FillDirection = Enum.FillDirection.Horizontal
    itemUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    itemUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    itemUIListLayout.Parent = keybindsItem

    keybinds.Parent = keybindsItem

    local keybindAction = Instance.new("TextLabel")
    keybindAction.Name = "KeybindAction"
    keybindAction.BackgroundTransparency = 1
    keybindAction.FontFace = Font.new(
        "rbxasset://fonts/families/Balthazar.json",
        Enum.FontWeight.Bold,
        Enum.FontStyle.Normal
    )

    keybindAction.LayoutOrder = 2
    keybindAction.Size = UDim2.fromScale(0.56, 0.7)
    keybindAction.Text = desc
    keybindAction.TextColor3 = Color3.new(1, 1, 1)
    keybindAction.TextScaled = true
    keybindAction.Parent = keybindsItem

    return keybindsItem
end

return function()
    local uiKeybindsList = Instance.new("Frame")
    uiKeybindsList.Name = "UI_KeybindsList"
    uiKeybindsList.BackgroundTransparency = 1
    uiKeybindsList.Position = UDim2.fromScale(0.78, 0.5)
    uiKeybindsList.Size = UDim2.fromScale(0.22, 0.4)

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Name = "UIListLayout"
    uiListLayout.Padding = UDim.new(0, 6)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = uiKeybindsList

    local uiPadding = Instance.new("UIPadding")
    uiPadding.Name = "UIPadding"
    uiPadding.PaddingTop = UDim.new(0, 6)
    uiPadding.Parent = uiKeybindsList

    for _, keybind in pairs(KeybindsList) do
        local keybindEntry = createKeybindEntry(keybind.desc, keybind.order, keybind.keybinds)
        keybindEntry.Parent = uiKeybindsList
    end

    return uiKeybindsList
end
