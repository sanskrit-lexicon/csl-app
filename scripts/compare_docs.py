#!/usr/bin/env python3
"""Compare documentation with codebase - RELIABLE VERSION."""

import re
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent
REFERENCE_DIR = PROJECT_ROOT / "reference"
LIB_DIR = PROJECT_ROOT / "lib"


def get_code_classes():
    """Get all class names from code."""
    classes = set()
    for f in LIB_DIR.rglob("*.dart"):
        content = f.read_text()
        for m in re.finditer(r'class\s+(\w+)', content):
            cn = m.group(1)
            if not cn.startswith('_'):
                classes.add((cn, str(f.relative_to(PROJECT_ROOT))))
    return classes


def get_private_code_classes():
    """Get private class names from code."""
    classes = set()
    for f in LIB_DIR.rglob("*.dart"):
        content = f.read_text()
        for m in re.finditer(r'class\s+(_[A-Z]\w+)', content):
            classes.add((m.group(1), str(f.relative_to(PROJECT_ROOT))))
    return classes


def get_doc_classes(md_file):
    """Get documented class names."""
    path = REFERENCE_DIR / md_file
    if not path.exists():
        return set()
    
    content = path.read_text()
    if '## Dependency Graph' in content:
        content = content[:content.find('## Dependency Graph')]
    
    classes = set()
    for m in re.finditer(r'#### Class: `(\w+)`', content):
        classes.add(m.group(1))
    return classes


def main():
    print("Checking documentation completeness...\n")
    
    # Code classes
    code_pub = get_code_classes()
    code_priv = get_private_code_classes()
    
    # Doc classes  
    doc_pub = get_doc_classes('public.md')
    doc_priv = get_doc_classes('private.md')
    
    print("="*50)
    print("PUBLIC API")
    print("="*50)
    
    # Missing from public docs
    missing_pub = {(c, f) for c, f in code_pub if c not in doc_pub}
    extra_pub = doc_pub - {c for c, f in code_pub}
    
    if missing_pub:
        print(f"\n⚠️  PUBLIC CLASSES NOT DOCUMENTED ({len(missing_pub)}):")
        for c, f in sorted(missing_pub):
            print(f"  + {c} ({f})")
    if extra_pub:
        print(f"\n📄 EXTRA IN DOCS: {extra_pub}")
    
    print("\n" + "="*50)
    print("PRIVATE API")
    print("="*50)
    
    missing_priv = {(c, f) for c, f in code_priv if c not in doc_priv}
    extra_priv = doc_priv - {c for c, f in code_priv}
    
    if missing_priv:
        print(f"\n⚠️  PRIVATE CLASSES NOT DOCUMENTED ({len(missing_priv)}):")
        for c, f in sorted(missing_priv):
            print(f"  + {c} ({f})")
    if extra_priv:
        print(f"\n📄 EXTRA IN DOCS: {extra_priv}")
    
    # Summary
    print("\n" + "="*50)
    total = len(missing_pub) + len(missing_priv)
    print(f"TOTAL: {total} missing classes")
    
    # For methods, do a simpler check
    print("\n" + "="*50)
    print("METHOD CHECK (basic)")
    print("="*50)
    
    # Just count documented methods
    doc_content = (REFERENCE_DIR / "public.md").read_text()
    doc_methods = re.findall(r'##### (?:Static )?Method: `(\w+)`', doc_content)
    print(f"Documented methods in public.md: {len(set(doc_methods))}")
    
    priv_content = (REFERENCE_DIR / "private.md").read_text()
    priv_methods = re.findall(r'##### (?:Static )?Method: `(\w+)`', priv_content)
    print(f"Documented methods in private.md: {len(set(priv_methods))}")
    
    if total == 0:
        print("\n✅ All classes documented!")
    else:
        print(f"\n⚠️  Update documentation with missing classes")


if __name__ == "__main__":
    main()
