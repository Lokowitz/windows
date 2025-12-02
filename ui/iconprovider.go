//go:build windows

package ui

import (
	"path/filepath"

	"github.com/fosrl/newt/logger"
	"github.com/fosrl/windows/config"
	"github.com/fosrl/windows/tunnel"
	"github.com/tailscale/walk"
)

type widthAndState struct {
	width int
	state tunnel.State
}

type widthAndDllIdx struct {
	width int
	idx   int32
	dll   string
}

var cachedOverlayIconsForWidthAndState = make(map[widthAndState]walk.Image)

// iconWithOverlayForState creates a composite icon with an overlay indicator for transitional states
// Returns walk.Image which can be used directly with SetIcon
func iconWithOverlayForState(state tunnel.State, size int) (icon walk.Image, err error) {
	// Check cache first
	icon = cachedOverlayIconsForWidthAndState[widthAndState{size, state}]
	if icon != nil {
		return
	}

	// Load base icon (gray for stopped, orange for running)
	var baseIcon *walk.Icon
	var iconName string
	if state == tunnel.StateRunning {
		iconName = "icon-orange.ico"
	} else {
		iconName = "icon-gray.ico"
	}

	iconPath := filepath.Join(config.GetIconsPath(), iconName)
	baseIcon, err = walk.NewIconFromFile(iconPath)
	if err != nil {
		logger.Error("Failed to load base icon from %s: %v", iconPath, err)
		// Fallback to system icon
		baseIcon, err = walk.NewIconFromResourceId(32517) // IDI_INFORMATION
		if err != nil {
			return nil, err
		}
	}

	// For stopped and running states, return base icon without overlay
	if state == tunnel.StateStopped || state == tunnel.StateRunning {
		// Convert icon to image for consistency (using paint function)
		// Use exact bounds matching to avoid color artifacts from stretching
		iconSize := baseIcon.Size()
		icon = walk.NewPaintFuncImage(walk.Size{Width: size, Height: size}, func(canvas *walk.Canvas, bounds walk.Rectangle) error {
			// If sizes match exactly, draw without stretching to avoid artifacts
			if iconSize.Width == bounds.Width && iconSize.Height == bounds.Height {
				return canvas.DrawImage(baseIcon, walk.Point{X: 0, Y: 0})
			}
			// Otherwise use stretched drawing (shouldn't happen if size matches)
			return canvas.DrawImageStretched(baseIcon, bounds)
		})
		cachedOverlayIconsForWidthAndState[widthAndState{size, state}] = icon
		return icon, nil
	}

	// For transitional states only, create composite with overlay
	iconSize := baseIcon.Size()
	w := int(float64(iconSize.Width) * 0.65)
	h := int(float64(iconSize.Height) * 0.65)
	overlayBounds := walk.Rectangle{X: iconSize.Width - w, Y: iconSize.Height - h, Width: w, Height: h}
	overlayIcon, err := iconForState(state, overlayBounds.Width)
	if err != nil {
		// If overlay fails, just return base icon
		icon = walk.NewPaintFuncImage(walk.Size{Width: size, Height: size}, func(canvas *walk.Canvas, bounds walk.Rectangle) error {
			return canvas.DrawImageStretched(baseIcon, bounds)
		})
		cachedOverlayIconsForWidthAndState[widthAndState{size, state}] = icon
		return icon, nil
	}

	// Create composite icon with overlay using paint function
	icon = walk.NewPaintFuncImage(walk.Size{Width: size, Height: size}, func(canvas *walk.Canvas, bounds walk.Rectangle) error {
		if err := canvas.DrawImageStretched(baseIcon, bounds); err != nil {
			return err
		}
		if err := canvas.DrawImageStretched(overlayIcon, overlayBounds); err != nil {
			return err
		}
		return nil
	})

	cachedOverlayIconsForWidthAndState[widthAndState{size, state}] = icon
	return
}

var cachedIconsForWidthAndState = make(map[widthAndState]*walk.Icon)

// iconForState returns an overlay icon for the given state
func iconForState(state tunnel.State, size int) (icon *walk.Icon, err error) {
	// Check cache first
	icon = cachedIconsForWidthAndState[widthAndState{size, state}]
	if icon != nil {
		return
	}

	switch state {
	case tunnel.StateRunning:
		// Active/connected state - use green checkmark
		icon, err = loadSystemIcon("imageres", -106, size)
	case tunnel.StateStopped:
		// Stopped state - no overlay needed
		icon, err = loadSystemIcon("shell32", -16739, size)
	default:
		// Transitional states (Starting, Registering, Registered, Stopping)
		// Use yellow warning icon
		icon, err = loadSystemIcon("shell32", -16739, size)
	}

	if err == nil {
		cachedIconsForWidthAndState[widthAndState{size, state}] = icon
	}
	return
}

var cachedSystemIconsForWidthAndDllIdx = make(map[widthAndDllIdx]*walk.Icon)

// loadSystemIcon loads an icon from a system DLL
func loadSystemIcon(dll string, index int32, size int) (icon *walk.Icon, err error) {
	// Check cache first
	icon = cachedSystemIconsForWidthAndDllIdx[widthAndDllIdx{size, index, dll}]
	if icon != nil {
		return
	}

	icon, err = walk.NewIconFromSysDLLWithSize(dll, int(index), size)
	if err == nil {
		cachedSystemIconsForWidthAndDllIdx[widthAndDllIdx{size, index, dll}] = icon
	}
	return
}
