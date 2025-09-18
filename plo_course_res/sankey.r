# ฟังก์ชันสร้างข้อมูลสำหรับ Sankey Diagram  
create_sankey_data <- function(complete_data) {
  
  # สร้าง nodes และ links สำหรับ Sankey
  nodes_courses <- complete_data %>%
    distinct(course_id, course_name_th) %>%
    mutate(
      node_id = paste0("course_", course_id),
      node_label = str_trunc(course_name_th, 40),
      level = 1,
      type = "course"
    )
  
  nodes_subplo <- complete_data %>%
    distinct(subplo_id, subplo_name_th, plo_id) %>%
    mutate(
      node_id = paste0("subplo_", subplo_id),
      node_label = paste0(subplo_id, ": ", str_trunc(subplo_name_th, 30)),
      level = 2,
      type = "subplo"
    )
  
  nodes_plo <- complete_data %>%
    distinct(plo_id, plo_name) %>%
    mutate(
      node_id = paste0("plo_", plo_id),
      node_label = paste0("PLO ", plo_id, ": ", str_trunc(plo_name, 25)),
      level = 3,
      type = "plo"
    )
  
  # รวม nodes
  all_nodes <- bind_rows(
    select(nodes_courses, node_id, node_label, level, type),
    select(nodes_subplo, node_id, node_label, level, type),  
    select(nodes_plo, node_id, node_label, level, type)
  ) %>%
    mutate(node_index = row_number() - 1)  # สำหรับ JavaScript (0-based index)
  
  # สร้าง links: Course → sub-PLO
  links_course_subplo <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(course_id, subplo_id) %>%
    summarise(
      strength = n(),  # จำนวน CLO connections
      .groups = "drop"
    ) %>%
    mutate(
      source_id = paste0("course_", course_id),
      target_id = paste0("subplo_", subplo_id),
      link_type = "course_subplo"
    )
  
  # สร้าง links: sub-PLO → PLO  
  links_subplo_plo <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(subplo_id, plo_id) %>%
    summarise(
      strength = n(),  # ใช้การนับแบบเดียวกันเพื่อความสมดุล
      .groups = "drop"
    ) %>%
    mutate(
      source_id = paste0("subplo_", subplo_id),
      target_id = paste0("plo_", plo_id),
      link_type = "subplo_plo"
    )
  
  # รวม links
  all_links <- bind_rows(
    select(links_course_subplo, source_id, target_id, strength, link_type),
    select(links_subplo_plo, source_id, target_id, strength, link_type)
  ) %>%
    left_join(all_nodes, by = c("source_id" = "node_id")) %>%
    rename(source_index = node_index) %>%
    select(-node_label, -level, -type) %>%
    left_join(all_nodes, by = c("target_id" = "node_id")) %>%
    rename(target_index = node_index) %>%
    select(source_index, target_index, strength, link_type)
  
  return(list(nodes = all_nodes, links = all_links))
}
