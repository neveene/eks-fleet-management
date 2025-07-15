# Changelog

## [0.0.8] - 2025-01-15

### Added

- Global values configuration in versions file to reduce duplication across release types
- Support for external chart repositories with configurable URLs and revisions
- Multiple release types (default, release1, release2) for monitoring configurations
- Enhanced fleet-secret chart with improved template helpers and external secret handling

### Changed

- Refactored hub-cluster bootstrap configurations (addons, monitoring, resources)
- Enhanced fleet-secret chart templates with better ECR token and git external secret handling
- Improved chart repository path handling for both local and remote repositories

### Technical Details

- Added template logic for dynamic repository URL selection in fleet/bootstrap application sets:
  ```yaml
  {{- else }}
    - repoURL: '{{default (index .metadata.annotations "chartRepoUrl") (index . "chartRepoUrl") }}'
      path:    '{{ default .values.chartPath (index . "chartRepoPath")}}'
      targetRevision: '{{default  (index .metadata.annotations "chartRepoRevision") (index . "chartRepoRevision") }}'
  {{- end }}
  ```
