class AddUniqueIndexes < ActiveRecord::Migration[8.0]
  def change
    # 이메일 유니크 인덱스 (이미 존재할 수 있으므로 안전하게 처리)
    add_index :users, :email, unique: true unless index_exists?(:users, :email, unique: true)

    # 수강신청 유니크 인덱스 (사용자 × 강의)
    add_index :enrollments, [ :user_id, :course_id ], unique: true unless index_exists?(:enrollments, [ :user_id, :course_id ], unique: true)

    # 리뷰 유니크 인덱스 (사용자 × 강의)
    add_index :reviews, [ :user_id, :course_id ], unique: true unless index_exists?(:reviews, [ :user_id, :course_id ], unique: true)

    # 장바구니 유니크 인덱스 (사용자 × 강의)
    add_index :cart_items, [ :user_id, :course_id ], unique: true unless index_exists?(:cart_items, [ :user_id, :course_id ], unique: true)
  end
end
