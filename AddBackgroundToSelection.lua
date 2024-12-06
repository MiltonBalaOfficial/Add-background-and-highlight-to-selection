-- Register UI elements and initialize
function initUi()
  app.registerUi({
      menu = "Add background to selection", 
      callback = "AddBackgroundToSelection", 
      -- Uncomment the following line to set a keyboard shortcut
      -- accelerator = "<Control>h",
      toolbarId = "addBackgroundToSelection", 
      iconName = "addBackgroundToSelection"
  })
  app.registerUi({
      menu = "Add highlight to selection", 
      callback = "AddHighlightToSelection", 
      -- Uncomment the following line to set a keyboard shortcut
      -- accelerator = "<Control>h",
      toolbarId = "addHighlightToSelection", 
      iconName = "addHighlightToSelection"
  })
end

-- Function to compute selection corners
function getCorners()
  -- Retrieve selection information
  local selInfo = app.getToolInfo("selection")
  if not selInfo then
      error("First select some strokes or texts!") -- Notify user if no selection
      return nil
  end

  local boundingBox = selInfo.boundingBox

  -- Compute the four corners of the bounding box
  local x1, y1 = boundingBox.x, boundingBox.y
  local x2, y2 = boundingBox.x + boundingBox.width, boundingBox.y
  local x3, y3 = boundingBox.x + boundingBox.width, boundingBox.y + boundingBox.height
  local x4, y4 = boundingBox.x, boundingBox.y + boundingBox.height

  -- Return the corners in table format
  return {
      x = {x1 + 10, x2 - 10, x3 - 10, x4 + 10},
      y = {y1 + 10, y2 + 10, y3 - 10, y4 - 10}
  }
end

-- Function to add a box (background or highlight) to the selection
function AddBoxToSelection(opacity, highlight)
  -- Get the corners of the selection
  local corners = getCorners()
  if not corners then return end -- Exit if no selection

  -- Retrieve the active pen color
  local activeColor = app.getToolInfo("pen")["color"]

  -- Define the box stroke
  local box = {
      x = {corners.x[1], corners.x[2], corners.x[3], corners.x[4], corners.x[1]}, -- Close the shape
      y = {corners.y[1], corners.y[2], corners.y[3], corners.y[4], corners.y[1]}, -- Close the shape
      width = 0.5, -- Stroke width
      fill = opacity, -- Fill opacity
      tool = "pen", -- Tool type
      color = activeColor -- Use the active pen color
  }

  -- Get the currently selected strokes and texts
  local strokes = app.getStrokes("selection") -- Retrieve strokes in selection
  local selectedTexts = app.getTexts("selection") -- Retrieve texts in selection

  if highlight then
      -- Add the highlight stroke over the selected Items
      app.addStrokes({ strokes = { box }, allowUndoRedoAction = "grouped" })
  else -- Adding background first then the selected Items again
      -- Add the background first
      app.addStrokes({ strokes = { box }, allowUndoRedoAction = "grouped" })

      -- Delete the current selection
      app.uiAction({ action = "ACTION_DELETE" })

      -- Re-add all selected texts if available
      if selectedTexts and #selectedTexts > 0 then
          app.addTexts({ texts = selectedTexts }) -- Re-add all selected texts
      end

      -- Re-add strokes if available
      if strokes and #strokes > 0 then
          app.addStrokes({ strokes = strokes, allowUndoRedoAction = "grouped" })
      end
  end

  -- Refresh the page to apply changes
  app.refreshPage()
end

-- Function to add a background to the selection
function AddBackgroundToSelection()
  AddBoxToSelection(255, false)
end

-- Function to add a highlight to the selection
function AddHighlightToSelection()
  AddBoxToSelection(50, true) -- If you need more opacity just increase the value as you like.
end
