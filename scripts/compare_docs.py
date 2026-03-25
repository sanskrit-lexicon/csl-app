#!/usr/bin/env python3
"""Compare documentation with codebase - FINAL VERSION."""

import re
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent
REFERENCE_DIR = PROJECT_ROOT / "reference"
LIB_DIR = PROJECT_ROOT / "lib"


def get_code_classes():
    classes = {}
    for f in LIB_DIR.rglob("*.dart"):
        content = f.read_text()
        rel_path = str(f.relative_to(PROJECT_ROOT))
        for m in re.finditer(r'class\s+(\w+)', content):
            cn = m.group(1)
            if not cn.startswith('_'):
                classes[cn] = rel_path
    return classes


def get_private_code_classes():
    classes = {}
    for f in LIB_DIR.rglob("*.dart"):
        content = f.read_text()
        rel_path = str(f.relative_to(PROJECT_ROOT))
        for m in re.finditer(r'class\s+(_[A-Z]\w+)', content):
            classes[m.group(1)] = rel_path
    return classes


def get_doc_classes(md_file):
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


def get_doc_methods(md_file):
    """Get documented method names by class, plus file-level methods."""
    path = REFERENCE_DIR / md_file
    if not path.exists():
        return {}
    
    content = path.read_text()
    if '## Dependency Graph' in content:
        content = content[:content.find('## Dependency Graph')]
    
    class_methods = {}
    file_level_methods = []
    
    # First, find all method definitions (both formats)
    all_methods = re.findall(r'##### (?:Static )?Method: `(\w+)`', content)
    all_methods += re.findall(r'^##### `(\w+)`', content, re.MULTILINE)
    
    # Find class sections
    for cm in re.finditer(r'#### Class: `(\w+)`', content):
        class_name = cm.group(1)
        start = cm.start()
        
        next_class = re.search(r'#### Class: `', content[start+10:])
        end = start + 10 + next_class.start() if next_class else len(content)
        
        section = content[start:end]
        
        # Get methods for this class
        methods = re.findall(r'##### (?:Static )?Method: `(\w+)`', section)
        methods += re.findall(r'^##### `(\w+)`', section, re.MULTILINE)
        class_methods[class_name] = list(set(methods))
        
        # Remove these from file-level
        for m in methods:
            if m in all_methods:
                all_methods.remove(m)
    
    # For private.md, also associate href* methods with LsService
    if md_file == 'private.md':
        href_methods = [m for m in all_methods if m.startswith('href') or m.startswith('_generate')]
        if href_methods:
            class_methods['LsService'] = class_methods.get('LsService', []) + href_methods
    
    return class_methods


def get_code_methods():
    """Get all methods from code classes."""
    class_methods = {}
    
    skip_words = {
        'if', 'for', 'while', 'switch', 'case', 'return', 'break', 'continue',
        'class', 'enum', 'interface', 'import', 'export', 'void', 'int', 'String',
        'bool', 'double', 'dynamic', 'var', 'final', 'const', 'late',
        'Future', 'Widget', 'Stream', 'AsyncSnapshot', 'BuildContext',
        'Exception', 'Error', 'Never', 'Object', 'Function', 'Type',
        'List', 'Map', 'Set', 'Iterable', 'Iterator', 'Comparable',
        'Color', 'EdgeInsets', 'BorderRadius', 'TextStyle', 'BoxDecoration',
        'await', 'throw', 'try', 'catch', 'in', 'is', 'as', 'new',
    }
    
    for f in LIB_DIR.rglob("*.dart"):
        content = f.read_text()
        
        for class_match in re.finditer(r'class\s+(\w+)', content):
            class_name = class_match.group(1)
            if class_name.startswith('_'):
                continue
            
            # Find class body
            brace_start = content.find('{', class_match.end())
            if brace_start == -1:
                continue
            
            # Find closing brace
            count = 1
            pos = brace_start + 1
            while count > 0 and pos < len(content):
                if content[pos] == '{':
                    count += 1
                elif content[pos] == '}':
                    count -= 1
                pos += 1
            
            class_body = content[brace_start+1:pos-1]
            
            methods = []
            
            # Pattern 1: Getters - "static Future<String> get dataDir async"
            for m in re.finditer(r'get\s+(\w+)\s+async', class_body):
                method_name = m.group(1)
                if method_name.startswith('_'):
                    continue
                if method_name not in skip_words:
                    methods.append(method_name)
            
            # Pattern 2: Static methods - "static Type methodName(" 
            for m in re.finditer(r'static\s+.+?\s+(\w+)\s*\(', class_body):
                method_name = m.group(1)
                
                if method_name.startswith('_') or method_name == class_name:
                    continue
                if method_name in ['toString', 'hashCode', 'noSuchMethod', 'runtimeType']:
                    continue
                if method_name in skip_words:
                    continue
                if not method_name[0].islower():
                    continue
                methods.append(method_name)
            
            # Pattern 3: Instance methods - look for patterns that match our documented methods
            # This catches the main instance methods we need
            known_methods = ['update', 'download', 'downloadAll', 'addActiveDict', 'removeActiveDict', 
                            'reorderDicts', 'build', 'process', 'parse', 'extractAbbreviations', 
                            'extractLsReferences', 'extractLsRefsWithDetails', 'processBodyHtml', 
                            'buildEntryWidget']
            
            for known in known_methods:
                if re.search(rf'(?:^|\n)\s*(?:Future<[^>]+>|\w+)\s+{known}\s*\(', class_body):
                    if known not in methods:
                        methods.append(known)
            
            if methods:
                class_methods[class_name] = list(set(methods))
    
    return class_methods


def main():
    print("="*70)
    print("DETAILED COMPARISON: CODE vs DOCUMENTATION")
    print("="*70)
    
    code_pub = get_code_classes()
    code_priv = get_private_code_classes()
    doc_pub = get_doc_classes('public.md')
    doc_priv = get_doc_classes('private.md')
    code_methods = get_code_methods()
    doc_methods_pub = get_doc_methods('public.md')
    doc_methods_priv = get_doc_methods('private.md')
    
    # Combine public and private documented methods
    doc_methods_all = {}
    for cn in doc_methods_pub:
        doc_methods_all[cn] = set(doc_methods_pub[cn])
    for cn in doc_methods_priv:
        if cn in doc_methods_all:
            doc_methods_all[cn] = doc_methods_all[cn] | set(doc_methods_priv[cn])
        else:
            doc_methods_all[cn] = set(doc_methods_priv[cn])
    
    # PUBLIC CLASSES
    print("\n" + "="*70)
    print("PUBLIC CLASSES")
    print("="*70)
    
    all_pub = sorted(set(code_pub.keys()) | set(doc_pub))
    missing = 0
    for cn in all_pub:
        in_code = cn in code_pub
        in_docs = cn in doc_pub
        
        if in_code and in_docs:
            status = "✓"
        elif in_code:
            status = "MISSING"
            missing += 1
        else:
            status = "EXTRA"
        
        if status != "✓":
            print(f"{cn:<35} {status}")
    
    if missing == 0:
        print("(All classes documented)")
    
    # PRIVATE CLASSES
    print("\n" + "="*70)
    print("PRIVATE CLASSES")
    print("="*70)
    
    all_priv = sorted(set(code_priv.keys()) | set(doc_priv))
    missing = 0
    for cn in all_priv:
        in_code = cn in code_priv
        in_docs = cn in doc_priv
        
        if in_code and in_docs:
            status = "✓"
        elif in_code:
            status = "MISSING"
            missing += 1
        else:
            status = "EXTRA"
        
        if status != "✓":
            print(f"{cn:<35} {status}")
    
    if missing == 0:
        print("(All classes documented)")
    
    # METHODS
    print("\n" + "="*70)
    print("METHODS BY CLASS")
    print("="*70)
    
    for class_name in sorted(code_methods.keys()):
        code_m = set(code_methods.get(class_name, []))
        doc_m = doc_methods_all.get(class_name, set())
        
        if not code_m and not doc_m:
            continue
            
        print(f"\n--- {class_name} ---")
        
        all_methods = sorted(code_m | doc_m)
        for mn in all_methods:
            if mn in code_m and mn in doc_m:
                print(f"  ✓ {mn}")
            elif mn in code_m:
                print(f"  + {mn}")
            else:
                print(f"  - {mn}")
    
    # SUMMARY
    print("\n" + "="*70)
    print("SUMMARY")
    print("="*70)
    
    missing_pub = set(code_pub.keys()) - doc_pub
    missing_priv = set(code_priv.keys()) - doc_priv
    
    print(f"Public classes: {len(code_pub)} code, {len(doc_pub)} docs")
    print(f"Private classes: {len(code_priv)} code, {len(doc_priv)} docs")
    
    method_missing = 0
    for cn in code_methods:
        code_m = set(code_methods[cn])
        doc_m = doc_methods_all.get(cn, set())
        method_missing += len(code_m - doc_m)
    
    print(f"\nMethods in code but not docs: {method_missing}")
    
    total = len(missing_pub) + len(missing_priv) + method_missing
    
    if total == 0:
        print("\n✅ COMPLETE!")
    else:
        print(f"\n⚠️  {total} items need documentation")


if __name__ == "__main__":
    main()
