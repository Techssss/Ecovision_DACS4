/**
 * YOLOv8 Class Names Translation
 * Model trained with: Graffiti, garbage, sand on road
 */

export const CLASS_NAMES_VI: Record<string, string> = {
  'Graffiti': 'Graffiti / Vẽ bậy',
  'garbage': 'Rác thải',
  'sand on road': 'Cát trên đường',
}

export const CLASS_ICONS: Record<string, string> = {
  'Graffiti': '🎨',
  'garbage': '🗑️',
  'sand on road': '🏖️',
}

export function getClassNameVI(className: string): string {
  return CLASS_NAMES_VI[className] || className
}

export function getClassIcon(className: string): string {
  return CLASS_ICONS[className] || '📦'
}

export function getClassColor(className: string): string {
  switch (className) {
    case 'Graffiti':
      return 'bg-purple-100 text-purple-800 border-purple-300'
    case 'garbage':
      return 'bg-red-100 text-red-800 border-red-300'
    case 'sand on road':
      return 'bg-yellow-100 text-yellow-800 border-yellow-300'
    default:
      return 'bg-gray-100 text-gray-800 border-gray-300'
  }
}
