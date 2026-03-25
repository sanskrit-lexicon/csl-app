#!/usr/bin/env python3
"""Compare documentation with actual codebase - FINAL."""

import re
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent
REFERENCE_DIR = PROJECT_ROOT / "reference"
LIB_DIR = PROJECT_ROOT / "lib"

def get_documented_items():
    docs = []
    content = (REFERENCE_DIR / "public.md").read_text()
    content = content[:content.find('## Dependency Graph')] if '## Dependency Graph' in content else content
    
    for fm in re.finditer(r'### \d+\. `([^`]+)`', content):
        file_path = fm.group(1)
        start = fm.end()
        end_match = re.search(r'\n### \d+\. ', content[start:])
        end = start + end_match.start() if end_match else len(content)
        section = content[start:end]
        
        for cm in re.finditer(r'#### Class: `([^`]+)`', section):
            docs.append((cm.group(1), 'class', file_path))
        
        for mm in re.finditer(r'##### (?:Static )?Method: `([^`]+)`', section):
            if '#### Class:' not in section[:mm.start()]:
                docs.append((mm.group(1), 'method', file_path))
    
    return docs

def get_codebase_items():
    code = []
    for dart_file in LIB_DIR.rglob("*.dart"):
        content = dart_file.read_text()
        rel_path = str(dart_file.relative_to(PROJECT_ROOT))
        
        # Classes - match any class declaration
        for m in re.finditer(r'class\s+(\w+)', content):
            cn = m.group(1)
            if not cn.startswith('_'):
                code.append((cn, 'class', rel_path))
        
        # Static methods at top level
        for m in re.finditer(r'static\s+(?:Future<[^>]+>|[^<\s]+)\s+(\w+)\s*\(', content):
            if not m.group(1).startswith('_'):
                if content[:m.start()].count('{') == content[:m.start()].count('}'):
                    code.append((m.group(1), 'method', rel_path))
    
    return code

def main():
    doc_items = get_documented_items()
    code_items = get_codebase_items()
    
    doc_classes = {d[0]: d for d in doc_items if d[1] == 'class'}
    code_classes = {c[0]: c for c in code_items if c[1] == 'class'}
    
    print("="*60)
    print("DOCUMENTATION vs CODEBASE")
    print("="*60)
    
    print(f"\nCLASSES: Code={len(code_classes)}, Docs={len(doc_classes)}")
    missing_c = sorted(set(code_classes.keys()) - set(doc_classes.keys()))
    extra_c = sorted(set(doc_classes.keys()) - set(code_classes.keys()))
    
    if missing_c:
        print(f"\n⚠️  NOT DOCUMENTED ({len(missing_c)}):")
        for c in missing_c:
            print(f"  + {c} ({code_classes[c][2]})")
    if extra_c:
        print(f"\n📄 NOT IN CODE ({len(extra_c)}):")
        for c in extra_c:
            print(f"  - {c} ({doc_classes[c][2]})")
    
    print(f"\nMETHODS:")
    doc_methods = {d[0]: d for d in doc_items if d[1] == 'method'}
    code_methods = {c[0]: c for c in code_items if c[1] == 'method'}
    print(f"  In code (standalone): {len(code_methods)}")
    print(f"  In docs: {len(doc_methods)}")
    
    total = len(missing_c) + len(extra_c)
    print(f"\n{'='*60}")
    print(f"TOTAL: {total} differences")
    if total == 0:
        print("✅ UP TO DATE!")

if __name__ == "__main__":
    main()
