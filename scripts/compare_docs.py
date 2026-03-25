#!/usr/bin/env python3
"""
Compare codebase with documentation to identify differences.
Run this script to check if documentation matches the current codebase.

Usage:
    python scripts/compare_docs.py
"""

import re
import sys
from pathlib import Path
from dataclasses import dataclass
from typing import Dict, List

PROJECT_ROOT = Path(__file__).parent.parent
LIB_DIR = PROJECT_ROOT / "lib"
REFERENCE_DIR = PROJECT_ROOT / "reference"


@dataclass
class DartClass:
    name: str
    file_path: str
    methods: List[Dict]


@dataclass
class DartFunction:
    name: str
    file_path: str


def extract_dart_code_items():
    """Extract all public classes and functions from Dart files."""
    classes = []
    functions = []
    
    for dart_file in LIB_DIR.rglob("*.dart"):
        try:
            content = dart_file.read_text()
            rel_path = str(dart_file.relative_to(PROJECT_ROOT))
        except Exception as e:
            continue
        
        # Extract classes
        for match in re.finditer(r'(?:^|\n)\s*(?:abstract\s+)?class\s+(\w+)\s*[{<]', content, re.MULTILINE):
            class_name = match.group(1)
            if not class_name.startswith('_'):
                methods = extract_class_methods(content, class_name)
                classes.append(DartClass(name=class_name, file_path=rel_path, methods=methods))
        
        # Extract static functions
        for match in re.finditer(r'(?:^|\n)\s*static\s+\w+\s+(\w+)\s*\(', content, re.MULTILINE):
            func_name = match.group(1)
            if not func_name.startswith('_'):
                functions.append(DartFunction(name=func_name, file_path=rel_path))
    
    return classes, functions


def extract_class_methods(content: str, class_name: str) -> List[Dict]:
    methods = []
    class_match = re.search(rf'class\s+{class_name}\s*[^{{]*\{{', content)
    if not class_match:
        return methods
    
    start = class_match.end()
    brace_count = 1
    for i, char in enumerate(content[start:], start):
        if char == '{':
            brace_count += 1
        elif char == '}':
            brace_count -= 1
            if brace_count == 0:
                end = i
                break
    
    class_body = content[start:end]
    for match in re.finditer(r'(?:^|\n)\s*(?:static\s+)?\w+\s+(\w+)\s*\(', class_body, re.MULTILINE):
        method_name = match.group(1)
        if (not method_name.startswith('_') and 
            method_name != class_name and
            method_name not in ['toString', 'hashCode', 'build', 'main']):
            methods.append({'name': method_name})
    return methods


def extract_docs_items():
    classes = {}
    functions = []
    public_file = REFERENCE_DIR / "public.md"
    if not public_file.exists():
        return classes, functions
    
    content = public_file.read_text()
    
    # Find all file sections
    file_pattern = r'### \d+\. `([^`]+)`'
    file_matches = list(re.finditer(file_pattern, content))
    
    for i, file_match in enumerate(file_matches):
        file_path = "lib/" + file_match.group(1).strip()
        section_start = file_match.end()
        section_end = file_matches[i+1].start() if i+1 < len(file_matches) else len(content)
        section = content[section_start:section_end]
        
        # Find classes
        for class_match in re.finditer(r'#### Class: `(\w+)`', section):
            class_name = class_match.group(1)
            methods = extract_documented_methods(section[class_match.start():])
            classes[class_name] = {'file': file_path, 'methods': methods}
        
        # Find standalone functions
        for method_match in re.finditer(r'##### (?:Static )?Method: `(\w+)`', section):
            method_name = method_match.group(1)
            method_pos = method_match.start()
            before = section[:method_pos]
            last_class = before.rfind('#### Class:')
            if last_class == -1:
                functions.append(DartFunction(name=method_name, file_path=file_path))
    
    return classes, functions


def extract_documented_methods(section: str) -> List[Dict]:
    methods = []
    for match in re.finditer(r'##### (?:Static )?Method: `(\w+)`', section):
        methods.append({'name': match.group(1)})
    return methods


def main():
    print("Scanning Dart files...")
    code_classes, code_functions = extract_dart_code_items()
    print(f"Found {len(code_classes)} classes, {len(code_functions)} functions in code")
    
    print("Parsing documentation...")
    doc_classes, doc_functions = extract_docs_items()
    print(f"Found {len(doc_classes)} classes, {len(doc_functions)} functions in docs")
    
    print("\n" + "="*80)
    print("COMPARISON RESULTS")
    print("="*80)
    
    code_class_names = {c.name: c for c in code_classes}
    code_class_set = set(code_class_names.keys())
    doc_class_set = set(doc_classes.keys())
    
    # CLASSES
    print("\n--- CLASSES ---")
    missing = code_class_set - doc_class_set
    extra = doc_class_set - code_class_set
    
    if missing:
        print(f"\n⚠️  NOT DOCUMENTED ({len(missing)}):")
        for name in sorted(missing):
            print(f"  + {name:<35} ({code_class_names[name].file_path})")
    
    if extra:
        print(f"\n📄 NOT IN CODE ({len(extra)}):")
        for name in sorted(extra):
            print(f"  - {name:<35} ({doc_classes[name]['file']})")
    
    # METHODS
    print("\n--- METHODS ---")
    common = code_class_set & doc_class_set
    method_diffs = 0
    for class_name in sorted(common):
        code_m = set(m['name'] for m in code_class_names[class_name].methods)
        doc_m = set(m['name'] for m in doc_classes[class_name]['methods'])
        missing_m = code_m - doc_m
        extra_m = doc_m - code_m
        if missing_m or extra_m:
            print(f"\n  Class: {class_name}")
            for m in sorted(missing_m):
                print(f"    + {m}")
                method_diffs += 1
            for m in sorted(extra_m):
                print(f"    - {m}")
                method_diffs += 1
    
    # FUNCTIONS
    print("\n--- FUNCTIONS ---")
    code_funcs = {(f.name, f.file_path) for f in code_functions}
    doc_funcs = {(f.name, f.file_path) for f in doc_functions}
    
    missing_f = code_funcs - doc_funcs
    extra_f = doc_funcs - code_funcs
    
    if missing_f:
        print(f"\n⚠️  NOT DOCUMENTED ({len(missing_f)}):")
        for name, path in sorted(missing_f)[:30]:  # Show first 30
            print(f"  + {name:<35} ({path})")
        if len(missing_f) > 30:
            print(f"  ... and {len(missing_f) - 30} more")
    
    if extra_f:
        print(f"\n📄 NOT IN CODE ({len(extra_f)}):")
        for name, path in sorted(extra_f):
            print(f"  - {name:<35} ({path})")
    
    # SUMMARY
    print("\n" + "="*80)
    print("SUMMARY")
    print("="*80)
    total = len(missing) + len(extra) + method_diffs + len(missing_f) + len(extra_f)
    print(f"Code classes: {len(code_class_set)}, Doc classes: {len(doc_class_set)}")
    print(f"Code funcs: {len(code_funcs)}, Doc funcs: {len(doc_funcs)}")
    print(f"Missing classes: {len(missing)}, Extra classes: {len(extra)}")
    print(f"Method differences: {method_diffs}")
    print(f"Missing funcs: {len(missing_f)}, Extra funcs: {len(extra_f)}")
    
    if total == 0:
        print("\n✅ Documentation is UP TO DATE!")
    else:
        print(f"\n⚠️  {total} differences found - update documentation!")


if __name__ == "__main__":
    main()
