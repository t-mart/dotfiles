{ pkgs, ... }:
let
  mergeKubeconfigs = pkgs.writeShellApplication {
    name = "merge-kubeconfigs";
    runtimeInputs = with pkgs; [
      coreutils
      kubectl
      yq-go
    ];
    text = ''
      kube_dir="$HOME/.kube"
      output="$kube_dir/config"
      temp_dir="$(mktemp --directory)"
      trap 'rm --recursive --force "$temp_dir"' EXIT

      mkdir --parents "$kube_dir"

      for context in bayleaf basil; do
        source_file="$kube_dir/$context.yaml"
        normalized_file="$temp_dir/$context.yaml"

        if [[ ! -f "$source_file" ]]; then
          echo "Missing kubeconfig: $source_file" >&2
          exit 1
        fi

        KUBECONFIG_CONTEXT="$context" yq eval '
          .clusters[].name = strenv(KUBECONFIG_CONTEXT) |
          .users[].name = strenv(KUBECONFIG_CONTEXT) |
          .contexts[].name = strenv(KUBECONFIG_CONTEXT) |
          .contexts[].context.cluster = strenv(KUBECONFIG_CONTEXT) |
          .contexts[].context.user = strenv(KUBECONFIG_CONTEXT) |
          .["current-context"] = strenv(KUBECONFIG_CONTEXT)
        ' "$source_file" > "$normalized_file"
      done

      KUBECONFIG="$temp_dir/bayleaf.yaml:$temp_dir/basil.yaml" \
        kubectl config view --flatten --raw > "$temp_dir/config"
      install --mode=0600 "$temp_dir/config" "$output"
    '';
  };
in
{
  home.packages = [
    pkgs.fluxcd
    pkgs.kubectl
    mergeKubeconfigs
  ];
}
